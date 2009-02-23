require 'admin_assistant/helper'
require 'admin_assistant/index'
require 'admin_assistant/request'

class AdminAssistant
  attr_reader :form_settings, :index_settings, :model_class,
              :params_filter_for_save
  attr_accessor :before_save, :destination_after_save

  def initialize(controller_class, model_class)
    @controller_class, @model_class = controller_class, model_class
    @form_settings = FormSettings.new self
    @index_settings = IndexSettings.new self
    @params_filter_for_save = {}
  end
  
  def method_missing(meth, *args)
    request_methods = [:create, :edit, :index, :new, :update]
    if request_methods.include?(meth) and args.size == 1
      controller = args.first
      controller.instance_variable_set :@admin_assistant, self
      klass = Request.const_get meth.to_s.capitalize
      @request = klass.new(self, controller)
      @request.call
      @request = nil
    elsif @request.respond_to?(meth)
      @request.send meth, *args
    else
      super
    end
  end
    
  def model_class_name
    model_class.name.gsub(/([A-Z])/, ' \1')[1..-1].downcase
  end
  
  def url_params(a = action)
    {:controller => @controller_class.controller_path, :action => a}
  end
  
  class Column
    def label
      if name.to_s == 'id'
        'ID'
      else
        name.to_s.capitalize.gsub(/_/, ' ') 
      end
    end
  end
  
  class ActiveRecordColumn < Column
    def initialize(ar_column)
      @ar_column = ar_column
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
      @name = name
    end
    
    def html_for_form(form)
      form.text_field name
    end
  end
  
  class Builder
    attr_reader :admin_assistant
    
    def initialize(admin_assistant)
      @admin_assistant = admin_assistant
    end
      
    def before_save(&block)
      @admin_assistant.before_save = block
    end
    
    def destination_after_save(&block)
      @admin_assistant.destination_after_save = block
    end
    
    def form
      yield @admin_assistant.form_settings
    end
      
    def index
      yield @admin_assistant.index_settings
    end
    
    def method_missing(meth, *args, &block)
      if meth.to_s =~ /(.*)_for_save/
        admin_assistant.params_filter_for_save[$1.to_sym] = block
      else
        super
      end
    end
  end
  
  module ControllerMethods
    def self.included(controller)
      controller.extend ControllerClassMethods
      controller.class_inheritable_accessor :admin_assistant
      controller.helper AdminAssistant::Helper
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
    def admin_assistant_for(model_class, &block)
      self.admin_assistant = AdminAssistant.new(self, model_class)
      builder = Builder.new self.admin_assistant
      if block
        block.call builder
      end
    end
  end
  
  class Settings
    def initialize(admin_assistant)
      @admin_assistant = admin_assistant
    end
    
    def columns_from_active_record(ar_columns)
      ar_columns.map { |ar_column| ActiveRecordColumn.new(ar_column) }
    end
      
    def columns_from_settings(column_syms)
      column_syms.map { |column_sym|
        ar_column = @admin_assistant.model_class.columns_hash[column_sym.to_s]
        if ar_column
          ActiveRecordColumn.new ar_column
        else
          AdminAssistantColumn.new column_sym
        end
      }
    end
  end
  
  class FormSettings < Settings
    attr_reader :inputs, :submit_buttons
    
    def initialize(admin_assistant)
      super
      @inputs = {}
      @submit_buttons = []
    end
    
    def columns(*args)
      if args.empty?
        if @columns
          columns_from_settings @columns
        else
          columns_from_active_record(
            @admin_assistant.model_class.columns.reject { |ar_column|
              %w(id created_at updated_at).include?(ar_column.name)
            }
          )
        end
      else
        @columns = args
      end
    end
  end
  
  class IndexSettings < Settings
    def columns(*args)
      if args.empty?
        if @columns
          columns_from_settings @columns
        else
          columns_from_active_record @admin_assistant.model_class.columns
        end
      else
        @columns = args
      end
    end
  end
end
