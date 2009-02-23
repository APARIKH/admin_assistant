require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::BlogPosts2Controller do
  integrate_views
  
  describe '#create' do
    describe 'when there are no validation errors' do
      before :each do
        title = random_word
        post(
          :create,
          :blog_post => {
            :title => title, :tags => 'tag1 tag2', :publish => '1'
          }
        )
        @blog_post = BlogPost.find_by_title title
      end
      
      it 'should create a new BlogPost' do
        @blog_post.should_not be_nil
      end
      
      it 'should create tags' do
        @blog_post.should have(2).tags
        %w(tag1 tag2).each do |tag_str|
          assert(@blog_post.tags.any? { |tag| tag.tag == tag_str })
        end
      end
      
      it 'should set published_at because of the publish flag' do
        @blog_post.published_at.should_not be_nil
      end
    end
    
    describe "when the user has clicked 'Preview'" do
      before :each do
        title = random_word
        post(
          :create,
          :blog_post => {
            :title => title, :tags => 'tag1 tag2', :publish => '1'
          },
          :commit => 'Preview'
        )
        @blog_post = BlogPost.find_by_title title
      end

      it 'should redirect to the edit page with the preview flag' do
        response.should redirect_to(
          :action => 'edit', :id => @blog_post.id, :preview => '1'
        )
      end
    end
  end
  
  describe '#edit' do
    before :all do
      BlogPost.destroy_all
      @blog_post = BlogPost.create!(
        :title => "blog post title", :body => 'blog post body'
      )
      tag1 = Tag.create! :tag => 'tag1'
      BlogPostTag.create! :blog_post => @blog_post, :tag => tag1
      tag2 = Tag.create! :tag => 'tag2'
      BlogPostTag.create! :blog_post => @blog_post, :tag => tag2
    end
      
    before :each do
      get :edit, :id => @blog_post.id
      response.should be_success
    end
    
    it 'should show the tags' do
      response.body.should match(%r|<input.*name="blog_post\[tags\]"|m)
      response.body.should match(/(tag2 tag1|tag1 tag2)/)
    end
    
    it 'should show a preview button' do
      response.should have_tag('input[type=submit][value=Preview]')
    end
  end
  
  describe '#edit in preview mode' do
    before :all do
      @blog_post = BlogPost.create!(
        :title => "blog post title", :body => 'blog post body'
      )
    end
    
    before :each do
      get :edit, :id => @blog_post.id, :preview => '1'
      response.should be_success
    end

    it 'should render the preview HTML' do
      response.should have_tag('h4', 'Preview')
    end
  end

  describe '#index' do
    describe 'when there is one record' do
      before :all do
        BlogPost.destroy_all
        @blog_post = BlogPost.create!(
          :title => "blog post title", :body => 'blog post body'
        )
        tag1 = Tag.create! :tag => 'tag1'
        BlogPostTag.create! :blog_post => @blog_post, :tag => tag1
        tag2 = Tag.create! :tag => 'tag2'
        BlogPostTag.create! :blog_post => @blog_post, :tag => tag2
      end
      
      before :each do
        get :index
        response.should be_success
      end
    
      it 'should show the tags' do
        response.body.should match(/(tag2 tag1|tag1 tag2)/)
      end
    
      it 'should show the title' do
        response.body.should match(/blog post title/)
      end
      
      it 'should not show the body' do
        response.body.should_not match(/blog post body/)
      end
    end
  end
  
  describe '#new' do
    before :all do
      Tag.create! :tag => 'tag_from_yesterday'
    end
    
    before :each do
      get :new
    end
    
    it 'should show a field for tags' do
      response.body.should match(%r|<input.*name="blog_post\[tags\]"|m)
    end
    
    it 'should show current tags' do
      response.body.should match(/tag_from_yesterday/)
    end
    
    it "should show a checkbox for the 'publish' virtual field" do
      response.body.should match(
        %r!
          <input[^>]*
          (name="blog_post\[publish\][^>]*type="checkbox"[^>]value="1"|
           type="checkbox"[^>]*name="blog_post\[publish\][^>]value="1")
        !x
      )
      # needs hidden field, like form.check_box
      response.body.should match(
        %r!
          <input[^>]*
          (name="blog_post\[publish\][^>]*type="hidden"[^>]value="0"|
          type="hidden"[^>]*name="blog_post\[publish\][^>]value="0")
        !x
      )
    end
    
    it 'should show a preview button' do
      response.should have_tag('input[type=submit][value=Preview]')
    end
  end
  
  describe '#update' do
    before :all do
      @blog_post = BlogPost.create! :title => random_word
    end
    
    describe "when the user has clicked 'Preview'" do
      before :each do
        title2 = random_word
        post(
          :update,
          :id => @blog_post.id, :blog_post => {:title => title2},
          :commit => 'Preview'
        )
      end
      
      it 'should redirect to the edit page with the preview flag' do
        response.should redirect_to(
          :action => 'edit', :id => @blog_post.id, :preview => '1'
        )
      end
    end
  end
end
