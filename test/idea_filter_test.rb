ENV['RACK_ENV'] = 'test'
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_box/idea_store'
require './lib/idea_box/idea_filter'

class IdeaFilterTest < Minitest::Test

  def setup
    IdeaStore.create("title" => "Monday",
                     "description" => "World",
                     "created_at" => "2013-10-14 01:12:25 -0600")
    IdeaStore.create("title" => "Tuesday",
                     "description" => "Partner",
                     "created_at" => "2013-10-15 02:04:25 -0600")
    IdeaStore.create("title" => "Wednesday",
                     "description" => "World",
                     "created_at" => "2013-10-16 03:12:25 -0600")
    IdeaStore.create("title" => "Thursday",
                     "description" => "Partner",
                     "created_at" => "2013-10-17 12:04:25 -0600")
    IdeaStore.create("title" => "Friday",
                     "description" => "World",
                     "created_at" => "2013-10-18 13:12:25 -0600")
    IdeaStore.create("title" => "Saturday",
                     "description" => "Partner",
                     "created_at" => "2013-10-19 14:04:25 -0600")
    IdeaStore.create("title" => "Sunday",
                     "description" => "World",
                     "created_at" => "2013-10-20 23:12:25 -0600")
    IdeaStore.create("title" => "Sunday",
                     "description" => "Partner",
                     "created_at" => "2013-10-13 12:04:25 -0600")
  end

  def teardown
    IdeaStore.destroy_database_contents
  end

  def test_it_exists
    assert IdeaFilter
  end

  def test_sorts_ideas_by_title
    filtered = IdeaFilter.new('title')
    expected = IdeaStore.sort_by_title
    assert_equal expected.first[0], filtered.ideas.first[0]
    assert_equal expected.last[0], filtered.ideas.last[0]
    assert_equal 'title', filtered.param
  end

  def test_sorts_ideas_by_day
    filtered = IdeaFilter.new('day')
    expected = IdeaStore.sort_by_day
    assert_equal expected.first.title, filtered.ideas.first.title
    assert_equal expected.last.title, filtered.ideas.last.title
    assert_equal 'day', filtered.param
  end

  def test_sorts_ideas_by_time
    skip
    filtered = IdeaFilter.new('time')
    expected = IdeaStore.sort_by_created_at_date
    assert_equal expected.first.title, filtered.ideas.first.title
    assert_equal expected.last.title, filtered.ideas.last.title
    assert_equal 'date created', filtered.param
  end

  def test_sorts_ideas_by_tag
    filtered = IdeaFilter.new('tag_count')
    expected = IdeaStore.sort_by_tag_count
    assert_equal expected.first.title, filtered.ideas.first.title
    assert_equal expected.last.title, filtered.ideas.last.title
    assert_equal 'tag count', filtered.param
  end
end
