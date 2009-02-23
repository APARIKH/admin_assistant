class AdminAssistant
  module Request
    class Base
      def initialize(admin_assistant, controller)
        @admin_assistant, @controller = admin_assistant, controller
      end
  
      def action
        @controller.action_name
      end
      
      def model_class
        @admin_assistant.model_class
      end
    
      def model_class_symbol
        model_class.name.underscore.to_sym
      end
      
      def params_for_save
        params = {}
        @controller.params[model_class_symbol].each do |k, v|
          if filter = @admin_assistant.params_filter_for_save[k.to_sym]
            params[k] = filter.call v
          elsif @record.respond_to?("#{k}=")
            params[k] = v
          end
        end
        params
      end
      
      def redirect_after_save
        url_params = if @admin_assistant.destination_after_save
          @admin_assistant.destination_after_save.call @controller, @record
        end
        url_params ||= {:action => 'index'}
        @controller.send :redirect_to, url_params
      end
      
      def render_edit
        render_form :locals => {:action => 'update', :id => @record.id}
      end
      
      def render_form(options_plus = {})
        options = {:file => template_file('form'), :layout => true}
        options = options.merge options_plus
        html = @controller.send(:render_to_string, options)
        after_form_html_template = File.join(
          RAILS_ROOT, 'app/views/', @controller.controller_path, 
          '_after_form.html.erb'
        )
        if File.exist?(after_form_html_template)
          partial_options = {
            :file => after_form_html_template, :layout => false
          }.merge options_plus
          html << @controller.send(:render_to_string, partial_options)
        end
        @controller.send :render, :text => html
      end

      def render_new
        render_form :locals => {:action => 'create'}
      end
      
      def render_template_file(template_name = action, options_plus = {})
        options = {:file => template_file(template_name), :layout => true}
        options = options.merge options_plus
        @controller.send(:render, options)
      end
      
      def save
        if @admin_assistant.before_save
          @admin_assistant.before_save.call(@record, @controller.params)
        end
        @record.save
      end
    
      def template_file(template_name = action)
        "#{RAILS_ROOT}/vendor/plugins/admin_assistant/lib/views/#{template_name}.html.erb"
      end
    end
    
    module FormMethods
      def columns
        @admin_assistant.form_settings.columns
      end
    end
    
    class Create < Base
      include FormMethods
      
      def call
        @record = model_class.new
        @record.attributes = params_for_save
        if save
          redirect_after_save
        else
          @controller.instance_variable_set :@record, @record
          render_new
        end
      end
    end
    
    class Edit < Base
      include FormMethods
      
      def call
        @record = model_class.find @controller.params[:id]
        @controller.instance_variable_set :@record, @record
        render_edit
      end
    end
    
    class Index < Base
      def call
        index = AdminAssistant::Index.new(model_class, @controller.params)
        @controller.instance_variable_set :@index, index
        render_template_file
      end
      
      def columns
        @admin_assistant.index_settings.columns
      end
    end
    
    class New < Base
      include FormMethods
      
      def call
        @controller.instance_variable_set :@record, model_class.new
        render_new
      end
    end
    
    class Update < Base
      include FormMethods
      
      def call
        @record = model_class.find @controller.params[:id]
        @record.attributes = params_for_save
        if save
          redirect_after_save
        else
          @controller.instance_variable_set :@record, @record
          render_edit
        end
      end
    end
  end
end
