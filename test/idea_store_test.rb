require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'yaml/store'
require './lib/idea_box/idea_store'
require './lib/idea_box/idea'

class IdeaStoreTest < Minitest::Test

  def setup
    IdeaStore.destroy_database_contents
    IdeaStore.database
    IdeaStore.create("title" => "Hello", "description" => "World")
    IdeaStore.create("title" => "Howdy", "description" => "howdy")
  end

  def teardown
    IdeaStore.destroy_database_contents
  end

  def test_the_database_exists
    assert_kind_of Psych::Store, IdeaStore.database
  end

  def test_it_creates_a_new_idea_and_stores_in_database
    result = IdeaStore.database.transaction {|db| db["ideas"].first}
    assert_equal "Hello", result["title"]
  end

  def test_all_gives_all_ideas_as_idea_objects
    assert_equal 2, IdeaStore.all.count
    assert_equal "Hello", IdeaStore.all.first.title
    assert_equal "Howdy", IdeaStore.all.last.title
  end

  def test_it_destroys_contents_of_database
    assert_equal 2, IdeaStore.all.count
    IdeaStore.destroy_database_contents
    assert_equal 0, IdeaStore.all.count
  end

  def test_it_deletes_an_idea_at_a_specific_position
    IdeaStore.delete(0)
    assert_equal 1, IdeaStore.all.count
    assert_equal "Howdy", IdeaStore.all.first.title
  end

  def test_it_finds_by_id
    result = IdeaStore.find(1)
    assert_equal 1, result.id
    assert_kind_of Idea, result
    assert_equal "Howdy", result.title
  end

  def test_it_can_update_an_idea
    assert_equal "Hello", IdeaStore.find(0).title
    assert_equal "World", IdeaStore.find(0).description
    IdeaStore.update(0, "title" => "Hola!")
    result = IdeaStore.find(0)
    assert_equal "Hola!", result.title
    assert_equal "World", result.description
  end

  def test_it_leaves_others_unchanged_when_updating_an_idea
    IdeaStore.update(0, "title" => "Hola!")
    result = IdeaStore.find(1)
    assert_equal "Howdy", result.title
  end

end
