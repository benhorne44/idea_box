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
    assert_equal "Hello", Idea.new(result).title
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
    assert_equal 2, IdeaStore.ideas_for_tags["english"].count
    assert_equal 1, IdeaStore.ideas_for_tags["spanish"].count
    assert_equal 2, IdeaStore.ideas_for_tags["no tag"].count
  end

  def test_it_does_not_duplicate_a_tag
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "tags" => "english, english")
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "tags" => "english")
    assert_equal ["english", "no tag"], IdeaStore.all_tags_for_ideas
  end

  def test_it_can_recognize_multiple_tags
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "tags" => "english, normal, hello")
    IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "tags" => "english")
    assert_equal 1, IdeaStore.ideas_for_tags["normal"].count
    assert_equal 2, IdeaStore.ideas_for_tags["english"].count
    assert_equal 1, IdeaStore.ideas_for_tags["hello"].count
    assert_equal 2, IdeaStore.ideas_for_tags["no tag"].count
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

  def test_it_can_search_for_a_word_in_an_idea
    IdeaStore.create("title"       => "Heyo Partner",
                     "description" => "good day sir",
                     "rank"        => 0,
                     "tags"        => "no tag",
                     "created_at"  => '2013-10-17 17:47:51.000000000 -06:00')
    assert_equal "Heyo Partner", IdeaStore.search('good').first.title
    assert_equal "good day sir", IdeaStore.search('Heyo').first.description
  end

  def test_search_is_not_case_sensitive
    IdeaStore.create("title"       => "Heyo Partner",
                     "description" => "good day sir",
                     "rank"        => 0,
                     "tags"        => "no tag",
                     "created_at"  => '2013-10-17 17:47:51.000000000 -06:00')
    assert_equal "Heyo Partner", IdeaStore.search('GoOD').first.title
  end

  def test_it_can_search_for_a_phrase
    IdeaStore.create("title"       => "Heyo Partner",
                     "description" => "Only two things are infinite,
                                       the universe and human stupidity,
                                       and I'm not sure about the former.",
                     "rank"        => 0,
                     "tags"        => "no tag",
                     "created_at"  => '2013-10-17 17:47:51.000000000 -06:00')
    assert_equal "Heyo Partner", IdeaStore.search("i'm Not SuRe").first.title
  end

  def test_it_can_sort_by_date_created
    IdeaStore.create("title"       => "Heyo Partner",
                     "description" => "Only two things are infinite,
                                       the universe and human stupidity,
                                       and I'm not sure about the former.",
                     "rank"        => 0,
                     "tags"        => "no tag",
                     "created_at"  => '2013-10-17 17:47:51.000000000 -06:00')
    results = IdeaStore.sort_by_created_at_date
    assert_equal "Heyo Partner", results.first.title
    assert_equal "Howdy", results.last.title
  end

  def test_it_can_sort_by_day_of_the_week
    IdeaStore.create("title"       => "Heyo Partner",
                     "description" => "Only two things are infinite,
                                       the universe and human stupidity,
                                       and I'm not sure about the former.",
                     "rank"        => 0,
                     "tags"        => "no tag",
                     "created_at"  => '2013-10-17 17:47:51.000000000 -06:00')
    results = IdeaStore.sort_by_day.map {|idea| idea.title}
    assert_equal ["Heyo Partner", "Hello", "Howdy"], results
  end

  def test_it_can_sort_by_title
    IdeaStore.create("title"       => "Heyo Partner",
                     "description" => "Only two things are infinite,
                                       the universe and human stupidity,
                                       and I'm not sure about the former.",
                     "rank"        => 0,
                     "tags"        => "no tag",
                     "created_at"  => '2013-10-17 17:47:51.000000000 -06:00')
    results = IdeaStore.sort_by_title.map { |idea| idea.first }
    assert_equal ["hello", "heyo partner", "howdy"], results
  end

  def test_it_can_sort_by_tag_count
    idea1 = IdeaStore.create("title" => "A",
                             "tags" => "green, blue, yellow")
    idea2 = IdeaStore.create("title" => "B",
                             "tags" => "green, blue")
    idea3 = IdeaStore.create("title" => "C",
                             "tags" => "green")
    results = IdeaStore.sort_by_tag_count.map {|idea| idea.title}
    assert_equal ["A", "B", "C", "Howdy", "Hello"], results
  end

  def test_it_tracks_revisions_for_an_idea
    idea = IdeaStore.create("title" => "Hello",
                     "description" => "World",
                     "tags" => "english, normal, hello")
    assert_equal 0, idea.revisions.count
    IdeaStore.update(idea.id.to_i, {"title" => "Heyo", "description" => "wookie"})
    assert_equal "Heyo", IdeaStore.find(idea.id.to_i).title
    assert_equal "Hello", IdeaStore.find(idea.id.to_i).revisions.first.title
    assert_equal 1, IdeaStore.find(idea.id.to_i).revisions.count
    IdeaStore.update(idea.id.to_i, {"title" => "Howdy", "description" => "jawa"})
    assert_equal 2, IdeaStore.find(idea.id.to_i).revisions.count
    assert_equal "Howdy", IdeaStore.find(idea.id.to_i).title
    assert_equal "jawa", IdeaStore.find(idea.id.to_i).description
    assert_equal "Hello", IdeaStore.find(idea.id.to_i).revisions.first.title
    assert_equal "World", IdeaStore.find(idea.id.to_i).revisions.first.description
    assert_equal "Heyo", IdeaStore.find(idea.id.to_i).revisions.last.title
    assert_equal "wookie", IdeaStore.find(idea.id.to_i).revisions.last.description
  end

  def test_all_produces_an_array_of_ideas
    assert_equal Array, IdeaStore.all.class
    assert_equal Idea, IdeaStore.all.first.class
  end

end
