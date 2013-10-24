ENV['RACK_ENV'] = 'test'
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/app'
require 'rack/test'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    IdeaBoxApp
  end

  def setup
    IdeaStore.database
    IdeaStore.create("title" => "hello",
                     "description" => "world" )
  end

  def teardown
    IdeaStore.destroy_database_contents
  end

  def test_it_find_the_homepage
    get '/'
    assert last_response.ok?
  end

  def test_it_creates_a_new_idea
    post '/', :idea => {"title" => "hola",
                       "description" => "mundo"}
    assert_equal 2, IdeaStore.all.count
    assert last_response.redirect?
  end

  def test_it_deletes_an_idea
    post '/', :idea => {"title" => "hola",
                       "description" => "mundo"}
    assert_equal 2, IdeaStore.all.count

    delete '/:id', :id => {"id" => 1}
    assert_equal 1, IdeaStore.all.count
    assert last_response.redirect?
  end

  def test_it_can_reach_edit_page
    get '/:id/edit', :id => {"id" => 0}
    assert last_response.ok?
  end

  def test_it_can_edit_existing_idea
    put '/:id', :idea => {"title" => "howdy"},
                :id => {"id" => 0}
    assert_equal "howdy", IdeaStore.all.first.title
    assert_equal "world", IdeaStore.all.first.description
  end

  def test_it_has_a_not_found_page
    get '/asodifj'
    assert (last_response.body =~ /An Error Occured/)
  end

  def test_it_can_like_an_idea
    assert_equal 0, IdeaStore.find(0).rank
    assert_equal "hello", IdeaStore.find(0).title

    post '/:id/like', :id => {"id" => 0}

    idea = IdeaStore.find(0)
    assert_equal 1, idea.rank
    assert_equal "hello", idea.title
    assert last_response.redirect?
  end

end
