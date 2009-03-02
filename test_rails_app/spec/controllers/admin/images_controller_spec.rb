require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ImagesController do
  integrate_views
=begin
  describe '#index' do
    before :all do
      @image = Image.create!(
        :image_file_name => '123.jpg', :image_content_type => 'image/jpeg', 
        :image_file_size => '456'
      )
    end
    
    before :each do
      get :index
      response.should be_success
    end
    
    it 'should show the image in-line as an <img> tag' do
      response.should have_tag("img[src=/images/#{@image.id}/original/123.jpg]")
    end
  end
=end
  
  describe '#new' do
    before :each do
      get :new
      response.should be_success
    end
    
    it "should have a multipart form" do
      response.should have_tag('form[enctype=multipart/form-data]')
    end
    
    it 'should have a file input for image' do
      response.body.should match(
        %r|<input[^>]*name="image\[image\]"[^>]*type="file"|
      )
    end
    
    it 'should not show paperclip-fields' do
      response.body.should_not match(/image_file_name/)
      response.body.should_not match(/image_content_type/)
      response.body.should_not match(/image_file_size/)
      response.body.should_not match(/image_updated_at/)
    end
  end
end
