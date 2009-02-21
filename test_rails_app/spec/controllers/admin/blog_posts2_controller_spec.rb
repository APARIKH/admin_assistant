require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::BlogPosts2Controller do
  integrate_views

  describe '#index' do
    describe 'when there is one record' do
      before :all do
        BlogPost.destroy_all
        @blog_post = BlogPost.create!(
          :title => "blog post title", :body => 'blog post body'
        )
      end
      
      before :each do
        get :index
        response.should be_success
      end
    
      it 'should show the title' do
        response.body.should match(/blog post title/)
      end
      
      it 'should not show the body' do
        response.body.should_not match(/blog post body/)
      end
    end
  end
end
