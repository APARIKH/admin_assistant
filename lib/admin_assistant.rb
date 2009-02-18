require File.expand_path(
  File.dirname(__FILE__) + '/../vendor/ar_query/lib/ar_query'
)

class AdminAssistant
  attr_accessor :model_class
  
  def initialize(model_class)
    @model_class = model_class
  end
  
  def method_missing(meth, *args)
    request_methods = [:create, :edit, :index, :new, :update]
    if request_methods.include?(meth) and args.size == 1
      Request.const_get(meth.to_s.capitalize).new(model_class, *args).call
    else
      super
    end
  end
  
  module ControllerMethods
    def self.included(controller)
      controller.extend ControllerClassMethods
      controller.cattr_accessor :admin_assistant
    end
    
    def create
      self.class.admin_assistant.create self
    end
    
    def edit
      self.class.admin_assistant.edit self
    end
  
    def index
      self.class.admin_assistant.index self
    end
    
    def new
      self.class.admin_assistant.new self
    end
    
    def update
      self.class.admin_assistant.update self
    end
  end
  
  module ControllerClassMethods
    def admin_assistant_for(model_class)
      self.admin_assistant = AdminAssistant.new(model_class)
    end
  end
  
  class Index
    def initialize(model_class, url_params = {})
      @model_class = model_class
      @url_params = url_params
    end
    
    def next_sort_params(column_name)
      next_sort_order = 'asc'
      if @url_params[:sort] == column_name
        if sort_order == 'asc'
          next_sort_order = 'desc'
        else
          column_name = nil
          next_sort_order = nil
        end
      end
      {:sort => column_name, :sort_order => next_sort_order}
    end
    
    def records
      unless @records
        order = 'id desc'
        if @url_params[:sort]
          order = "#{@url_params[:sort] } #{sort_order}"
        end
        ar_query = ARQuery.new(:order => order, :limit => 25)
        ar_query.boolean_join = :or
        if search_terms
          searchable_columns = @model_class.columns.select { |column|
            [:string, :text].include?(column.type)
          }
          searchable_columns.each do |column|
            ar_query.condition_sqls << "#{column.name} like ?"
            ar_query.bind_vars << "%#{search_terms}%"
          end
        end
        @records = @model_class.find :all, ar_query
      end
      @records
    end
    
    def search_terms
      @url_params['search']
    end
    
    def sort_order
      @url_params[:sort_order] || 'asc'
    end
  end
  
  module Request
    class Base
      attr_reader :model_class
      
      def initialize(model_class, controller)
        @model_class, @controller = model_class, controller
        @controller.instance_variable_set :@admin_assistant_request, self
      end
      
      def action
        self.class.name.split(/::/).last.downcase
      end
    
      def model_class_name
        model_class.name.gsub(/([A-Z])/, ' \1')[1..-1].downcase
      end
    
      def model_class_symbol
        model_class.name.underscore.to_sym
      end
      
      def render_edit
        render_template_file(
          'form', :locals => {:action => 'update', :id => @record.id}
        )
      end

      def render_new
        render_template_file 'form', :locals => {:action => 'create'}
      end
      
      def render_template_file(template_name = action, options_plus = {})
        options = {:file => template_file(template_name), :layout => true}
        options = options.merge options_plus
        @controller.send(:render, options)
      end
    
      def template_file(template_name = action)
        "#{RAILS_ROOT}/vendor/plugins/admin_assistant/lib/views/#{template_name}.html.erb"
      end
  
      def url_params(a = action)
        {:controller => @controller.controller_name, :action => a}
      end
    end
    
    class Create < Base
      def call
        record = model_class.new @controller.params[model_class_symbol]
        if record.save
          @controller.send :redirect_to, :action => 'index'
        else
          @controller.instance_variable_set :@record, record
          render_new
        end
      end
    end
    
    class Edit < Base
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
    end
    
    class New < Base
      def call
        @controller.instance_variable_set :@record, model_class.new
        render_new
      end
    end
    
    class Update < Base
      def call
        @record = model_class.find @controller.params[:id]
        @record.attributes = @controller.params[model_class_symbol]
        if @record.save
          @controller.send :redirect_to, :action => 'index'
        else
          @controller.instance_variable_set :@record, @record
          render_edit
        end
      end
    end
  end
end
