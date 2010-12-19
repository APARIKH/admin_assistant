ENV["RAILS_ENV"] = "test"
here = File.dirname(__FILE__)
require File.expand_path(here + "/../config/environment")
require 'test_help'

module TestHelper
  def assert_a_tag_with_get_args(
    content, href_base, href_get_args, response_body
  )
    regex = %r|<a href="#{ href_base }\?([^"]*)"[^>]*>#{ content }</a>|
    assert(
      response_body =~ regex,
      "#{response_body.inspect} expected to match #{regex.inspect}"
    )
    assert_get_args_equal( href_get_args, $1.gsub( /&amp;/, '&' ) )
  end
  
  def assert_no_a_tag_with_get_args(
    content, href_base, href_get_args, response_body
  )
    regex = %r|<a href="#{ href_base }\?([^"]*)"[^>]*>#{ content }</a>|
    if response_body =~ regex
      get_args_string = $1.gsub( /&amp;/, '&' )
      response_h = HashWithIndifferentAccess.new
      CGI::parse( get_args_string ).each do |key, values|
        response_h[key] = values.first
      end
      if href_get_args.size == response_h.size
        raise if href_get_args.all? { |key, value|
          response_h[key] == value
        }
      end
    end
  end
  
  def assert_get_args_equal( expected_hash, get_args_string )
    response_h = HashWithIndifferentAccess.new
    CGI::parse( get_args_string ).each do |key, values|
      response_h[key] = values.first
    end
    assert_equal(
      expected_hash.size, response_h.size,
      "<#{ expected_hash.inspect }> expected but was\n<#{ response_h.inspect }>."
    )
    expected_hash.each do |key, value|
      assert_equal( value, response_h[key] )
    end
  end

  def random_word( length = 25 )
    letters = 'abcdefghijklmnopqrstuvwxyz_'.split //
    ( 1..length ).to_a.map { letters[rand(letters.size)] }.join( '' )
  end
end

class CacheStoreStub
  def initialize
    flush
  end
  
  def expires_in(key)
    @expirations[key.to_s]
  end
  
  def flush
    @cache = {}
    @expirations = {}
    @raise_on_write = false
  end
  
  def raise_on_write
    @raise_on_write = true
  end
  
  def read(key, options = nil)
    @cache[key.to_s]
  end
  
  def write(key, value, options = nil)
    raise if @raise_on_write
    @cache[key.to_s] = value
    @expirations[key.to_s] = options[:expires_in]
  end
end

$cache = CacheStoreStub.new

module Rails
  mattr_accessor :cache
  self.cache = $cache
end

if %w(2.1.0 2.1.2).include?(RAILS_GEM_VERSION)
  class Test::Unit::TestCase
    self.use_transactional_fixtures = true
  
    self.use_instantiated_fixtures  = false
  
    include TestHelper
  end
else
  class ActiveSupport::TestCase
    self.use_transactional_fixtures = true
  
    self.use_instantiated_fixtures  = false
    
    include TestHelper
  end
end

Webrat.configure do |config|  
  config.mode = :rails  
end  

