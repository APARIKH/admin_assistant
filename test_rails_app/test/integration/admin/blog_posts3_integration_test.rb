require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class Admin::BlogPosts3IntegrationTest < ActionController::IntegrationTest
  def setup
    User.destroy_all
    @user = User.create! :username => 'soren', :password => 'password'
  end
  
  def test_create_with_no_title
    @orig_blog_post_count = BlogPost.count
    post "/admin/blog_posts3/create", :blog_post => {:user_id => @user.id}
    
    # should redirect to the index
    assert_redirected_to(:action => 'index')
    
    # should create a new blog post with the title pre-filled as (draft)
    assert_equal(@orig_blog_post_count + 1, BlogPost.count)
    blog_post = BlogPost.last
    assert_equal('(draft)', blog_post.title)
  end
  
  def test_edit
    @blog_post = BlogPost.create! :title => random_word, :user => @user
    get "/admin/blog_posts3/edit/#{@blog_post.id}"
    
    # should have a body field
    assert_select('textarea[name=?]', 'blog_post[body]')
    
    # should not include textile
    assert_no_match(/textile/, response.body)
  end
  
  def test_index_with_no_blog_posts
    BlogPost.destroy_all
    get "/admin/blog_posts3"
    assert_response :success

    # should use the activescaffold-themed CSS
    assert_select(
      'link[href^=/stylesheets/admin_assistant/activescaffold.css]'
    )
  
    # should say 'Posts'
    assert_select('h2', :text => 'Posts')
  end
    
  def test_index_with_one_unpublished_blog_post
    BlogPost.destroy_all
    @blog_post = BlogPost.create!(
      :title => "unpublished blog post", :user => @user,
      :published_at => nil
    )
    $cache.flush
    get "/admin/blog_posts3"
    
    # should show the blog post
    assert_match(/unpublished blog post/, response.body)
    
    # should show 'No' from having called BlogPost#published?
    assert_select("tr[id=blog_post_#{@blog_post.id}]") do
      assert_select "td", :text => 'No'
    end
  
    # should not have a comparator for the ID search field
    assert_select('form[id=search_form][method=get]') do
      assert_select("select[name=?]", "search[id(comparator)]", false)
    end
    
    # should have a blank checkbox for the body search field
    assert_select('form[id=search_form][method=get]') do
      assert_select("input[type=checkbox][name=?]", "search[body(blank)]")
    end
    
    # should render extra action links in order
    assert_match(/Short title.*Blank body/m, response.body)
    
    # should have a trinary select for the has_short_title search field
    assert_select('form[id=search_form][method=get]') do
      assert_select('select[name=?]', 'search[has_short_title]') do
        assert_select("option[value='']", :text => '')
        assert_select("option[value='true']", :text => 'Yes')
        assert_select("option[value='false']", :text => 'No')
      end
    end
  
    # should show a search form with specific fields
    assert_select(
      'form[id=search_form][method=get]', :text => /Title/
    ) do
      assert_select('input[name=?]', 'search[title]')
      assert_select('input[name=?]', 'search[body]')
      assert_select('select[name=?]', 'search[textile]') do
        assert_select("option[value='']", :text => '')
        assert_select("option[value='true']", :text => 'true')
        assert_select("option[value='false']", :text => 'false')
      end
      assert_select('label', :text => 'User')
      assert_select('input[name=?]', 'search[user]')
    end
    
    # should set the count in memcache
    key =
        "AdminAssistant::Admin::BlogPosts3Controller_count_published_at_is_null_"
    assert_equal(1, $cache.read(key))
    assert_in_delta(12.hours, $cache.expires_in(key), 5.seconds)
    
    # should not make the textile field an Ajax toggle
    toggle_div_id = "blog_post_#{@blog_post.id}_textile"
    assert_no_match(%r|new Ajax.Updater\('#{toggle_div_id}'|, response.body)
  end
    
  def test_index_with_a_published_blog_post
    $cache.flush
    BlogPost.destroy_all
    BlogPost.create!(
      :title => "published blog post", :user => @user,
      :published_at => Time.now.utc
    )
    get "/admin/blog_posts3"
    
    # should not show the blog post
    assert_no_match(/published blog post/, response.body)
    assert_match(/No posts found/, response.body)
  end
  
  def test_index_when_searching_by_user
    User.destroy_all
    tiffany = User.create!(:username => 'tiffany')
    BlogPost.create! :title => "By Tiffany", :user => tiffany
    BlogPost.create!(
      :title => "Already published", :user => tiffany,
      :published_at => Time.now
    )
    bill = User.create! :username => 'bill', :password => 'parsimony'
    BlogPost.create! :title => "By Bill", :user => bill
    brooklyn_steve = User.create!(
      :username => 'brooklyn_steve', :state => 'NY'
    )
    BlogPost.create! :title => "By Brooklyn Steve", :user => brooklyn_steve
    sadie = User.create!(
      :username => 'Sadie', :password => 'sadie', :state => 'KY'
    )
    BlogPost.create! :title => "By Sadie", :user => sadie
    get(
      "/admin/blog_posts3",
      :search => {
        :body => "", :textile => "", :id => "", :user => 'ny',
        :has_short_title => ''
      }
    )
    assert_response :success
    
    # should match the string to the username
    assert_match(/By Tiffany/, response.body)
    
    # should match the string to the password
    assert_match(/By Bill/, response.body)
    
    # should match the string to the state
    assert_match(/By Brooklyn Steve/, response.body)
    
    # should skip blog posts that don't match anything on the user
    assert_no_match(/By Sadie/, response.body)
    
    # should skip blog posts that have already been published
    assert_no_match(/Already published/, response.body)
  end
  
  def test_index_with_blog_posts_from_two_different_users
    aardvark_man = User.create!(:username => 'aardvark_man')
    BlogPost.create! :title => 'AARDVARKS!!!!!1', :user => aardvark_man
    ziggurat = User.create!(:username => 'zigguratz')
    BlogPost.create! :title => "Wanna go climbing?", :user => ziggurat
    get "/admin/blog_posts3"
    assert_response :success
      
    # should sort by username
    assert_match(%r|AARDVARKS!!!!!1.*Wanna go climbing|m, response.body)
  end
end
