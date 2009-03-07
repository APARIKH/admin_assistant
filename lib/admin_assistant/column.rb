class AdminAssistant
  module ColumnsMethods
    def columns_without_options
      column_names = @admin_assistant.send(
        "#{self.class.name.split(/::/).last.downcase}_settings"
      ).column_names
      column_names = default_column_names unless column_names
      columns = paperclip_attachments.map { |paperclip_attachment|
        PaperclipColumn.new paperclip_attachment
      }
      column_names.each do |column_name|
        if columns.all? { |column| !column.contains?(column_name) }
          ar_column =
              @admin_assistant.model_class.columns_hash[column_name.to_s]
          if ar_column
             columns << ActiveRecordColumn.new(ar_column)
          else
            columns << AdminAssistantColumn.new(column_name)
          end
        end
      end
      columns
    end
    
    def model_class
      @admin_assistant.model_class
    end
    
    def paperclip_attachments
      pa = []
      if model_class.respond_to?(:attachment_definitions)
        if model_class.attachment_definitions
          pa = model_class.attachment_definitions.map { |name, definition|
            name
          }
        end
      end
      pa
    end
  end
  
  class Column
    attr_accessor :sort_order
    
    def label
      if name.to_s == 'id'
        'ID'
      else
        name.to_s.capitalize.gsub(/_/, ' ') 
      end
    end
    
    def index_header_css_class
      "sort #{sort_order}" if sort_order
    end
    
    def index_td_css_class
      'sort' if sort_order
    end
  end
  
  class ActiveRecordColumn < Column
    def initialize(ar_column)
      @ar_column = ar_column
    end
    
    def add_to_form(form)
      case @ar_column.type
        when :text
          form.text_area name
        when :boolean
          form.check_box name
        else
          form.text_field name
        end
    end
    
    def contains?(column_name)
      column_name.to_s == @ar_column.name
    end
    
    def name
      @ar_column.name
    end
    
    def type
      @ar_column.type
    end
  end
  
  class AdminAssistantColumn < Column
    attr_reader :name
    
    def initialize(name)
      @name = name.to_s
    end
    
    def contains?(column_name)
      column_name.to_s == @name
    end
  end
  
  class PaperclipColumn < Column
    attr_reader :name
    
    def initialize(name)
      @name = name.to_s
    end
    
    def add_to_form(form)
      form.file_field name
    end
    
    def contains?(column_name)
      column_name.to_s == @name ||
      column_name.to_s =~
          /^#{@name}_(file_name|content_type|file_size|updated_at)$/
    end
  end
end
