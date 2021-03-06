# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "admin_assistant"
  s.version = "2.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Francis Hwang"]
  s.date = "2012-02-21"
  s.description = "admin_assistant is a Rails plugin that automates a lot of features typically needed in admin interfaces."
  s.email = "sera@fhwang.net"
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "MIT-LICENSE",
    "README",
    "Rakefile",
    "VERSION",
    "admin_assistant.gemspec",
    "config/routes.rb",
    "doc/img/blog_posts-index.png",
    "lib/admin_assistant.rb",
    "lib/admin_assistant/active_record_column.rb",
    "lib/admin_assistant/association_target.rb",
    "lib/admin_assistant/belongs_to_column.rb",
    "lib/admin_assistant/builder.rb",
    "lib/admin_assistant/column.rb",
    "lib/admin_assistant/default_search_column.rb",
    "lib/admin_assistant/form_view.rb",
    "lib/admin_assistant/has_many_column.rb",
    "lib/admin_assistant/helper.rb",
    "lib/admin_assistant/index.rb",
    "lib/admin_assistant/init.rb",
    "lib/admin_assistant/model.rb",
    "lib/admin_assistant/paperclip_column.rb",
    "lib/admin_assistant/polymorphic_belongs_to_column.rb",
    "lib/admin_assistant/request/autocomplete.rb",
    "lib/admin_assistant/request/base.rb",
    "lib/admin_assistant/request/create.rb",
    "lib/admin_assistant/request/destroy.rb",
    "lib/admin_assistant/request/edit.rb",
    "lib/admin_assistant/request/index.rb",
    "lib/admin_assistant/request/new.rb",
    "lib/admin_assistant/request/show.rb",
    "lib/admin_assistant/request/update.rb",
    "lib/admin_assistant/route.rb",
    "lib/admin_assistant/search.rb",
    "lib/admin_assistant/show_view.rb",
    "lib/admin_assistant/virtual_column.rb",
    "lib/views/_polymorphic_field_search.html.erb",
    "lib/views/_token_input.html.erb",
    "lib/views/form.html.erb",
    "lib/views/index.html.erb",
    "lib/views/multi_form.html.erb",
    "lib/views/show.html.erb",
    "rails_3_0/lib/tasks/.gitkeep",
    "rails_3_0/public/stylesheets/.gitkeep",
    "rails_3_0/vendor/plugins/.gitkeep",
    "rails_3_1/app/mailers/.gitkeep",
    "rails_3_1/lib/assets/.gitkeep",
    "rails_3_1/lib/tasks/.gitkeep",
    "rails_3_1/log/.gitkeep",
    "rails_3_1/vendor/plugins/.gitkeep",
    "tasks/admin_assistant_tasks.rake",
    "uninstall.rb",
    "vendor/ar_query/MIT-LICENSE",
    "vendor/ar_query/README",
    "vendor/ar_query/ar_query.gemspec",
    "vendor/ar_query/init.rb",
    "vendor/ar_query/install.rb",
    "vendor/ar_query/lib/ar_query.rb",
    "vendor/ar_query/spec/ar_query_spec.rb",
    "vendor/ar_query/tasks/ar_query_tasks.rake",
    "vendor/ar_query/uninstall.rb",
    "vendor/assets/images/sort-asc.png",
    "vendor/assets/images/sort-desc.png",
    "vendor/assets/javascripts/admin_assistant.js",
    "vendor/assets/javascripts/jquery.tokeninput.js",
    "vendor/assets/stylesheets/admin_assistant.css",
    "vendor/assets/stylesheets/admin_assistant_activescaffold.css",
    "vendor/assets/stylesheets/token-input.css",
    "website/_layouts/api.html",
    "website/_layouts/api1.html",
    "website/_layouts/default.html",
    "website/api/core.markdown",
    "website/api/destroy.markdown",
    "website/api/form.markdown",
    "website/api/idx.markdown",
    "website/api/index.markdown",
    "website/api/search.markdown",
    "website/api/show.markdown",
    "website/community.markdown",
    "website/css/lightbox.css",
    "website/css/main.css",
    "website/design_principles.markdown",
    "website/getting_started.markdown",
    "website/img/blog_posts-index.png",
    "website/img/blog_posts-search.png",
    "website/img/lightbox/bullet.gif",
    "website/img/lightbox/close.gif",
    "website/img/lightbox/closelabel.gif",
    "website/img/lightbox/donate-button.gif",
    "website/img/lightbox/download-icon.gif",
    "website/img/lightbox/image-1.jpg",
    "website/img/lightbox/loading.gif",
    "website/img/lightbox/nextlabel.gif",
    "website/img/lightbox/prevlabel.gif",
    "website/img/lightbox/thumb-1.jpg",
    "website/img/screen1-thumb.png",
    "website/img/screen1.png",
    "website/img/screen10-thumb.png",
    "website/img/screen10.png",
    "website/img/screen11-thumb.png",
    "website/img/screen11.png",
    "website/img/screen2-thumb.png",
    "website/img/screen2.png",
    "website/img/screen3-thumb.png",
    "website/img/screen3.png",
    "website/img/screen4-thumb.png",
    "website/img/screen4.png",
    "website/img/screen5-thumb.png",
    "website/img/screen5.png",
    "website/img/screen6-thumb.png",
    "website/img/screen6.png",
    "website/img/screen7-thumb.png",
    "website/img/screen7.png",
    "website/img/screen8-thumb.png",
    "website/img/screen8.png",
    "website/img/screen9-thumb.png",
    "website/img/screen9.png",
    "website/img/user-form.png",
    "website/index.markdown",
    "website/js/builder.js",
    "website/js/effects.js",
    "website/js/lightbox.js",
    "website/js/prototype.js",
    "website/js/scriptaculous.js",
    "website/quick_start.markdown",
    "website/screenshots.markdown",
    "website/tutorial.markdown",
    "website/v1/api/core.markdown",
    "website/v1/api/destroy.markdown",
    "website/v1/api/form.markdown",
    "website/v1/api/idx.markdown",
    "website/v1/api/index.markdown",
    "website/v1/api/search.markdown",
    "website/v1/api/show.markdown",
    "website/v1/index.markdown",
    "website/v1/quick_start.markdown",
    "website/v1/tutorial.markdown"
  ]
  s.homepage = "http://github.com/fhwang/admin_assistant"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "admin_assistant is a Rails plugin that automates a lot of features typically needed in admin interfaces."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<will_paginate>, ["~> 3.0"])
      s.add_runtime_dependency(%q<dynamic_form>, [">= 0"])
    else
      s.add_dependency(%q<will_paginate>, ["~> 3.0"])
      s.add_dependency(%q<dynamic_form>, [">= 0"])
    end
  else
    s.add_dependency(%q<will_paginate>, ["~> 3.0"])
    s.add_dependency(%q<dynamic_form>, [">= 0"])
  end
end

