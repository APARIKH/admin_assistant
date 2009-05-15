class Admin::FileColumnImages2Controller < ApplicationController
  layout 'admin'

  admin_assistant_for FileColumnImage do |a|
    a.index do |i|
      i.columns :image
      i[:image].image_size = '300x500'
    end
  end
end
