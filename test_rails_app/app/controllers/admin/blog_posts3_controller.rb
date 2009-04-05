class Admin::BlogPosts3Controller < ApplicationController
  layout 'admin'

  admin_assistant_for BlogPost do |a|
    a.index do |index|
      index.total_entries = lambda { 25 }
      
      # By default, only show unpublished blog posts unless params[:all] is
      # passed in. This needs to work with or without use of the field search
      # feature
      index.conditions do |params|
        "published_at is null" unless params[:all]
      end
    end
  end
end
