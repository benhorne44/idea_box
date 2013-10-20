ENV['RACK_ENV'] = 'test'
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
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "created_at" => "2013-10-19 01:12:25 -0600'")
    IdeaStore.create("title" => "Howdy",
                     "description" => "Partner",
                     "created_at" => "2013-10-19 12:04:25 -0600'")
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

  def test_it_groups_by_tag
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "tags" => "english")
    IdeaStore.create("title" => "Hola",
                     "description" => "Mundo",
                     "tags" => "spanish")
    IdeaStore.create("title" => "Howdy",
                     "description" => "Partner",
                     "tags" => "english")
    assert_equal 2, IdeaStore.tag_hash["english"].count
    assert_equal 1, IdeaStore.tag_hash["spanish"].count
    assert_equal 2, IdeaStore.tag_hash["no tag"].count
  end

  def test_it_can_recognize_multiple_tags
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "tags" => "english, normal, hello")
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "tags" => "english")
    assert_equal 1, IdeaStore.tag_hash["normal"].count
    assert_equal 2, IdeaStore.tag_hash["english"].count
    assert_equal 1, IdeaStore.tag_hash["hello"].count
    assert_equal 2, IdeaStore.tag_hash["no tag"].count
  end

  def test_it_can_recognize_a_created_at_value
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "created_at" => '2013-10-17 16:42:53 -0600')

  end

  def test_it_can_find_by_day_of_the_week

    IdeaStore.create("title"       => "Thursday Idea",
                     "description" => "chicken BBQ",
                     "rank"        => 0,
                     "tags"        => "no tag",
                     "created_at"  => '2013-10-17 17:47:51.000000000 -06:00')

    assert_equal 1, IdeaStore.find_by_day('Thu').count
    assert_equal "Thursday Idea", IdeaStore.find_by_day('Thu').first.title
    assert_equal 2, IdeaStore.find_by_day('Sat').count
    assert_equal "Hello", IdeaStore.find_by_day('Sat').first.title
    assert_equal "Howdy", IdeaStore.find_by_day('Sat').last.title
  end

  def test_it_can_find_by_time_of_day
    saturday = IdeaStore.find_by_time('12')
    assert_equal 1, saturday.count
    assert_equal "Howdy", saturday.first.title
  end

end
