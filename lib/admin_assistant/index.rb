require 'ar_query'

class AdminAssistant
  class Index
    def initialize(admin_assistant, url_params = {})
      @admin_assistant = admin_assistant
      @url_params = url_params
    end
    
    def add_search_terms(ar_query)
      searchable_columns.each do |column|
        ar_query.condition_sqls << "#{column.name} like ?"
        ar_query.bind_vars << "%#{search_terms}%"
      end
    end
    
    def belongs_to_sort_column
      columns.detect { |column|
        column.is_a?(BelongsToColumn) && column.name.to_s == @url_params[:sort]
      }
    end
    
    def columns
      column_names =  @admin_assistant.index_settings.column_names ||
          model_class.columns.map { |c|
            @admin_assistant.column_name_or_assoc_name(c.name)
          }
      @admin_assistant.columns column_names
    end
    
    def conditions
      @admin_assistant.index_settings.conditions
    end
    
    def find_include
      if by_assoc = belongs_to_sort_column
        by_assoc.name
      end
    end
    
    def model_class
      @admin_assistant.model_class
    end
    
    def order_sql
      if (sc = sort_column)
        first_part = if (by_assoc = belongs_to_sort_column)
          by_assoc.order_sql_field
        else
          sc.name
        end
        "#{first_part} #{sort_order}"
      else
        @admin_assistant.index_settings.sort_by
      end
    end
    
    def records
      unless @records
        ar_query = ARQuery.new(
          :order => order_sql, :include => find_include,
          :per_page => 25, :page => @url_params[:page]
        )
        ar_query.boolean_join = :or
        add_search_terms(ar_query) if search_terms
        if conditions
          conditions_sql = conditions.call @url_params
          ar_query.condition_sqls << conditions_sql if conditions_sql
        end
        @records = model_class.paginate :all, ar_query
      end
      @records
    end
    
    def searchable_columns
      model_class.columns.select { |column|
        [:string, :text].include?(column.type)
      }
    end
    
    def search_terms
      @url_params['search']
    end
    
    def settings
      @admin_assistant.index_settings
    end
    
    def sort
      @url_params[:sort]
    end
    
    def sort_column
      if @url_params[:sort]
        columns.detect { |c|
          c.name.to_s == @url_params[:sort]
        } || belongs_to_sort_column
      end
    end
    
    def sort_order
      @url_params[:sort_order] || 'asc'
    end
    
    def view(action_view)
      View.new self, action_view
    end
    
    class View
      def initialize(index, action_view)
        @index, @action_view = index, action_view
      end
      
      def columns
        @index.columns.map { |c|
          c.view(
            @action_view,
            :boolean_labels => @index.settings.boolean_labels[c.name],
            :sort_order => (@index.sort_order if c.name == @index.sort)
          )
        }
      end
    end
  end
end
