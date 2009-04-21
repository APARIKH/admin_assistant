class AdminAssistant
  class Column
    attr_reader :custom_label, :search_terms
    
    def initialize(opts)
      @custom_label = opts[:custom_label]
      @search_terms = opts[:search_terms]
    end

    def view(action_view, opts = {})
      klass = self.class.const_get 'View'
      klass.new self, action_view, opts
    end
    
    def form_view(action_view, opts = {})
      klass = self.class.const_get 'FormView'
      klass.new self, action_view, opts
    end
  
    class View < Delegator
      attr_reader :sort_order
      
      def initialize(column, action_view, opts)
        super(column)
        @column, @action_view, @opts = column, action_view, opts
        @boolean_labels = opts[:boolean_labels]
        @link_to_args = opts[:link_to_args] # index only
        @search = opts[:search] # search only
        @sort_order = opts[:sort_order] # index only
        if respond_to?(:set_instance_variables_from_options)
          set_instance_variables_from_options opts
        end
      end
      
      def __getobj__
        @column
      end
      
      def __setobj__(column)
        @column = column
      end
      
      def index_ajax_toggle?
        false
      end

      def index_header_css_class
        "sort #{sort_order}" if sort_order
      end
      
      def index_td_css_class
        'sort' if sort_order
      end
      
      def index_html(record)
        html_for_index_method = "#{name}_html_for_index"
        html = if @action_view.respond_to?(html_for_index_method)
          @action_view.send html_for_index_method, record
        elsif @link_to_args
          @action_view.link_to(
            @action_view.send(:h, index_value(record)),
            @link_to_args.call(record)
          )
        elsif index_ajax_toggle?
          index_ajax_toggle_html(record)
        else
          @action_view.send(:h, index_value(record))
        end
        html = '&nbsp;' if html.blank?
        html
      end
      
      def index_value(record)
        value_method = "#{@column.name}_value"
        if @action_view.respond_to?(value_method)
          @action_view.send value_method, record
        else
          field_value record
        end
      end
      
      def label
        if @column.custom_label
          @column.custom_label
        elsif @column.name.to_s == 'id'
          'ID'
        else
          @column.name.to_s.capitalize.gsub(/_/, ' ') 
        end
      end
    
      def next_sort_params
        name_for_sort = name
        next_sort_order = 'asc'
        if sort_order
          if sort_order == 'asc'
            next_sort_order = 'desc'
          else
            name_for_sort = nil
            next_sort_order = nil
          end
        end
        {:sort => name_for_sort, :sort_order => next_sort_order}
      end
      
      def paperclip?
        @column.is_a?(PaperclipColumn)
      end
      
      def sort_possible?
        @column.is_a?(ActiveRecordColumn) || @column.is_a?(BelongsToColumn)
      end
    end
    
    module FormViewMethods
      def value(record)
        value_method = "#{@column.name}_value"
        if @action_view.respond_to?(value_method)
          @action_view.send value_method, record
        else
          field_value record
        end
      end
      
      def set_instance_variables_from_options(opts)
        @input = opts[:input]
      end
    end
  end
  
  class ActiveRecordColumn < Column
    def initialize(ar_column, opts)
      super opts
      @ar_column = ar_column
    end
    
    def add_to_query_condition(ar_query_condition)
      unless @search_terms.blank?
        case sql_type
          when :boolean
            ar_query_condition.sqls << "#{name} = ?"
            ar_query_condition.bind_vars << search_value
          else
            ar_query_condition.sqls << "#{name} like ?"
            ar_query_condition.bind_vars << "%#{@search_terms}%"
        end
      end
    end
    
    def contains?(column_name)
      column_name.to_s == @ar_column.name
    end
    
    def name
      @ar_column.name
    end
    
    def search_value
      case sql_type
        when :boolean
          @search_terms.blank? ? nil : (@search_terms == 'true')
        else
          @search_terms
      end
    end
    
    def sql_type
      @ar_column.type
    end
    
    class View < AdminAssistant::Column::View
      def field_value(record)
        record.send(name) if record.respond_to?(name)
      end

      def index_ajax_toggle?
        @column.sql_type == :boolean
      end
      
      def index_ajax_toggle_div_id(record)
        "#{record.class.name.underscore}_#{record.id}_#{name}"
      end
      
      def index_ajax_toggle_html(record)
        <<-HTML
        <div id="#{ index_ajax_toggle_div_id(record) }">
        #{index_ajax_toggle_inner_html(record)}
        </div>
        HTML
      end
      
      def index_ajax_toggle_inner_html(record)
        div_id = index_ajax_toggle_div_id record
        @action_view.link_to_remote(
          index_value(record),
          :update => div_id,
          :url => {
            :action => 'update', :id => record.id, :from => div_id,
            record.class.name.underscore.to_sym => {
              name => (!index_value(record) ? '1' : '0')
            }
          },
          :success => "$(#{div_id}).hide(); $(#{div_id}).appear()"
        )
      end

      def index_value(record)
        value = super
        if @boolean_labels
          value = value ? @boolean_labels.first : @boolean_labels.last
        end
        value
      end
      
      def search_html
        input = case @column.sql_type
          when :boolean
            opts = [['', nil]]
            if @boolean_labels
              opts << [@boolean_labels.first, true]
              opts << [@boolean_labels.last, false]
            else
              opts << ['true', true]
              opts << ['false', false]
            end
            @action_view.select("search", name, opts)
          else
            @action_view.text_field_tag("search[#{name}]", @search[name])
        end
        "<p><label>#{label}</label> <br/>#{input}</p>"
      end
    end
    
    class FormView < View
      include AdminAssistant::Column::FormViewMethods
      
      def add_to_form(form)
        case @input || @column.sql_type
          when :text
            form.text_area name
          when :boolean
            form.check_box name
          when :datetime
            form.datetime_select name, :include_blank => true
          when :date
            form.date_select name, :include_blank => true
          when :us_state
            form.select(
              name, ordered_us_state_names_and_codes, :include_blank => true
            )
          else
            form.text_field name
          end
      end
      
      def ordered_us_state_names_and_codes
        {
          'Alabama' => 'AL', 'Alaska' => 'AK', 'Arizona' => 'AZ',
          'Arkansas' => 'AR', 'California' => 'CA', 'Colorado' => 'CO', 
          'Connecticut' => 'CT', 'Delaware' => 'DE',
          'District of Columbia' => 'DC', 'Florida' => 'FL', 'Georgia' => 'GA',
          'Hawaii' => 'HI', 'Idaho' => 'ID', 'Illinois' => 'IL',
          'Indiana' => 'IN', 'Iowa' => 'IA', 'Kansas' => 'KS',
          'Kentucky' => 'KY', 'Louisiana' => 'LA', 'Maine' => 'ME',
          'Maryland' => 'MD', 'Massachusetts' => 'MA', 'Michigan' => 'MI', 
          'Minnesota' => 'MN', 'Mississippi' => 'MS', 'Missouri' => 'MO', 
          'Montana' => 'MT', 'Nebraska' => 'NE', 'Nevada' => 'NV',
          'New Hampshire' => 'NH', 'New Jersey' => 'NJ', 'New Mexico' => 'NM', 
          'New York' => 'NY', 'North Carolina' => 'NC', 'North Dakota' => 'ND',
          'Ohio' => 'OH', 'Oklahoma' => 'OK', 'Oregon' => 'OR',
          'Pennsylvania' => 'PA', 'Puerto Rico' => 'PR',
          'Rhode Island' => 'RI', 'South Carolina' => 'SC',
          'South Dakota' => 'SD', 'Tennessee' => 'TN', 'Texas' => 'TX',
          'Utah' => 'UT', 'Vermont' => 'VT', 'Virginia' => 'VA',
          'Washington' => 'WA', 'West Virginia' => 'WV', 'Wisconsin' => 'WI', 
          'Wyoming' => 'WY'
        }.sort_by { |name, code| name }
      end
    end
  end
  
  class AdminAssistantColumn < Column
    attr_reader :name
    
    def initialize(name, opts)
      super opts
      @name = name.to_s
    end
    
    def contains?(column_name)
      column_name.to_s == @name
    end
    
    class View < AdminAssistant::Column::View
      def field_value(record)
        nil
      end
    end
    
    class FormView < View
      include AdminAssistant::Column::FormViewMethods
    end
  end
  
  class BelongsToColumn < Column
    attr_reader :search_terms
    
    def initialize(belongs_to_assoc, opts)
      super opts
      @belongs_to_assoc = belongs_to_assoc
    end
    
    def add_to_query_condition(ar_query_condition)
      unless @search_terms.blank?
        ar_query_condition.ar_query.joins << name.to_sym
        ar_query_condition.add_condition do |sub_cond|
          sub_cond.boolean_join = :or
          AdminAssistant.searchable_columns(associated_class).each do |column|
            sub_cond.sqls <<
                "#{associated_class.table_name}.#{column.name} like ?"
            sub_cond.bind_vars << "%#{@search_terms}%"
          end
        end
      end
    end
    
    def associated_class
      @belongs_to_assoc.klass
    end
    
    def association_foreign_key
      @belongs_to_assoc.association_foreign_key
    end
    
    def contains?(column_name)
      column_name.to_s == name
    end
    
    def default_name_method
      [:name, :title, :login, :username].detect { |m|
        associated_class.columns.any? { |column| column.name.to_s == m.to_s }
      }
    end
    
    def name
      @belongs_to_assoc.name.to_s
    end
    
    def order_sql_field
      sql = "#{@belongs_to_assoc.table_name}. "
      sql << if default_name_method
        default_name_method.to_s
      else
        @belongs_to_assoc.association_foreign_key
      end
    end
    
    class View < AdminAssistant::Column::View
      def field_value(record)
        assoc_value = record.send name
        if assoc_value.respond_to?(:name_for_admin_assistant)
          assoc_value.name_for_admin_assistant
        elsif assoc_value && default_name_method
          assoc_value.send default_name_method
        end
      end
      
      def search_html
        input = @action_view.text_field_tag(
          "search[#{name}]", @column.search_terms
        )
        "<p><label>#{label}</label> <br/>#{input}</p>"
      end
    end
    
    class FormView < View
      include AdminAssistant::Column::FormViewMethods
      
      def add_to_form(form)
        form.select(
          association_foreign_key,
          associated_class.
              find(:all).
              sort_by { |model| model.send(default_name_method) }.
              map { |model| [model.send(default_name_method), model.id] }
        )
      end
    end
  end
  
  class DefaultSearchColumn < Column
    def initialize(terms, model_class)
      super({:search_terms => terms})
      @model_class = model_class
    end
    
    def add_to_query_condition(ar_query_condition)
      unless @search_terms.blank?
        ar_query_condition.ar_query.boolean_join = :or
        AdminAssistant.searchable_columns(@model_class).each do |column|
          ar_query_condition.sqls << "#{column.name} like ?"
          ar_query_condition.bind_vars << "%#{@search_terms}%"
        end
      end
    end
    
    class View < AdminAssistant::Column::View
      def search_html
        @action_view.text_field_tag("search", @column.search_terms)
      end
    end
    
    class FormView < View
      include AdminAssistant::Column::FormViewMethods
    end
  end
  
  class FileColumnColumn < Column
    attr_reader :name
    
    def initialize(name, opts)
      super opts
      @name = name.to_s
    end
    
    def contains?(column_name)
      column_name.to_s == @name
    end
    
    class View < AdminAssistant::Column::View      
      def index_html(record)
        @action_view.instance_variable_set :@record, record
        @action_view.image_tag(
          @action_view.url_for_file_column('record', @column.name)
        )
      end
    end
    
    class FormView < View
      include AdminAssistant::Column::FormViewMethods
      
      def add_to_form(form)
        form.file_field name
      end
    end
  end
  
  class PaperclipColumn < Column
    attr_reader :name
    
    def initialize(name, opts = {})
      super opts
      @name = name.to_s
    end
    
    def contains?(column_name)
      column_name.to_s == @name ||
      column_name.to_s =~
          /^#{@name}_(file_name|content_type|file_size|updated_at)$/
    end
    
    class View < AdminAssistant::Column::View
      def index_html(record)
        @action_view.image_tag record.send(@column.name).url
      end
    end
    
    class FormView < View
      include AdminAssistant::Column::FormViewMethods
      
      def add_to_form(form)
        form.file_field name
      end
    end
  end
end
