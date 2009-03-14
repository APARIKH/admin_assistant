class AdminAssistant
  module Helper
    def admin_assistant_includes
      stylesheet_link_tag 'admin_assistant'
    end
    
    def controller_css_class
      controller.controller_path.gsub(%r|/|, '_')
    end
    
    def html_for_index(column, record)
      html_for_index_method = "#{column.name}_html_for_index"
      hfi = if respond_to?(html_for_index_method)
        self.send html_for_index_method, record
      elsif column.respond_to?(:index_html)
        column.index_html record
      else
        value = column.index_value record
        if column.respond_to?(:sql_type) && column.sql_type == :boolean
          custom = @admin_assistant.index_settings.boolean_labels[column.name]
          if custom
            value = value ? custom.first : custom.last
          end
        end
        h value
      end
      hfi = '&nbsp;' if hfi.blank?
      hfi
    end
  end
end
