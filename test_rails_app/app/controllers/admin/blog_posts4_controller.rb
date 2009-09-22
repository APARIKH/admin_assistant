class Admin::BlogPosts4Controller < ApplicationController
  layout 'admin'

  admin_assistant_for BlogPost do |a|
    a[:published_at].strftime_format = "%b %d, %Y %H:%M:%S"
    
    a.index do |index|
      index.columns :user, :title, :tags, :published_at, :textile
      index.search :id, :title, :body, :textile, :user, :published_at
      
      index.total_entries do
        25
      end
    end
  end
end
