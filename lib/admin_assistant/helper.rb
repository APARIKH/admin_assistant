class AdminAssistant
  module Helper
    def admin_assistant_includes
      stylesheet_link_tag 'admin_assistant'
    end
    
    def after_html_for_form(column, record)
      after_html_template = File.join(
        RAILS_ROOT, 'app/views', controller.controller_path,
        "_after_#{column.name}_html_for_form.html.erb"
      )
      if File.exist?(after_html_template)
        render(
          :file => after_html_template,
          :locals => {
            @admin_assistant.model_class.name.underscore.to_sym => record
          }
        )
      end
    end
    
    def field_value(record, column)
      value_method = "#{column.name}_value"
      fv = if respond_to?(value_method)
        self.send value_method, record
      elsif column.respond_to?(:field_value)
        column.field_value record
      end
      if fv.nil? && record.respond_to?(column.name)
        fv = record.send(column.name)
      end
      fv
    end
    
    def html_for_form_column_and_record(column, record)
      input_name =
          "#{@admin_assistant.model_class.name.underscore}[#{column.name}]"
      input_type = @admin_assistant.form_settings.inputs[column.name.to_sym]
      if input_type
        if input_type == :check_box
          check_box_tag(input_name, '1', field_value(record, column)) +
              hidden_field_tag(input_name, '0')
        end
      else
        text_field_tag(input_name, field_value(record, column))
      end
    end
    
    def html_for_form(column, record, form)
      html_method = "#{column.name}_html_for_form"
      hff = respond_to?(html_method) && self.send(html_method, record)
      hff ||= if column.respond_to?(:add_to_form)
        column.add_to_form(form)
      else
        html_for_form_column_and_record column, record
      end
      if ah = after_html_for_form(column, record)
        hff << ah
      end
      hff
    end
    
    def html_for_index(column, record)
      html_for_index_method = "#{column.name}_html_for_index"
      hfi = if respond_to?(html_for_index_method)
        self.send html_for_index_method, record
      elsif column.is_a?(PaperclipColumn)
        image_tag(record.send(column.name).url)
      else
        h(field_value(record, column))
      end
      hfi = '&nbsp;' if hfi.blank?
      hfi
    end
  end
end
