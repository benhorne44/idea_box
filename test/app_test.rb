gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/app'
require 'rack/test'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    IdeaboxApp
  end

  def test_hello
    get '/'
    assert_equal "Hello, world", last_response.body
  end

  # def test_create_new_idea
  #   post '/', {idea: {title: "exercise", description: "sign up for yoga"}}
  #   idea = IdeaStore.all.first
  #   assert_equal "exercise", idea.title
  #   assert_equal "sign up for yoga", idea.description
  # end
end
