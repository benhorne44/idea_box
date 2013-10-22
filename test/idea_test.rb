ENV['RACK_ENV'] = 'test'
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_box/idea'

class IdeaTest < Minitest::Test

  def test_basic_idea
    idea = Idea.new("title"       => "dinner",
                    "description" => "chicken BBQ",
                    "id"          => "1")
    assert_equal "dinner", idea.title
    assert_equal "chicken BBQ", idea.description
    assert_equal "1", idea.id
  end

  def test_it_gets_a_rank_of_0_initially
    idea = Idea.new
    assert_equal 0, idea.rank
  end

  def test_like_method_raises_the_rank
    idea = Idea.new
    assert_equal 0, idea.rank
    idea.like!
    assert_equal 1, idea.rank
  end

  def test_spaceship_operator_compares_votes
    idea = Idea.new
    bad_idea = Idea.new
    assert_equal 0, idea.<=>(bad_idea)
    idea.like!
    assert_equal -1, idea.<=>(bad_idea)
    bad_idea.like!
    bad_idea.like!
    assert_equal 1, idea.<=>(bad_idea)
  end

  def test_it_can_sort_by_rank

  end

  def test_an_idea_has_a_tag_by_default
    idea = Idea.new
    assert_equal "no tag", idea.tags
  end

  def test_it_can_add_a_tag
    idea = Idea.new("tags" => "idea")
    assert_equal "idea", idea.tags
  end

  def test_it_can_have_a_created_at_value
    idea = Idea.new("created_at" => '2013-10-17 16:42:53 -0600')

    assert_equal '2013-10-17 16:42:53 -0600', idea.created_at
  end

  def test_it_can_have_an_updated_at_value
    time = Time.now
    idea = Idea.new("updated_at" => time)

    assert_equal "#{time}", idea.updated_at.to_s
  end

  def test_it_has_a_time_parse_feature
    idea = Idea.new("created_at" => '2013-10-17 17:47:51.000000000 -06:00')
    assert (idea.time_parse =~ /Thu/)
  end

  def test_it_has_no_revisions_by_default
    idea = Idea.new
    assert_equal [], idea.revisions
  end

  def test_it_tracks_revisions
    time = '2013-10-17 16:42:53 -0600'
    idea = Idea.new("title"       => "dinner",
                    "description" => "chicken BBQ",
                    "id"          => "1",
                    "updated_at"   => time)
    idea.revisions << idea
    assert_equal 1, idea.revisions.count
    assert_equal Idea, idea.revisions.first.class
  end

  def test_it_can_merge_ideas
    idea1 = Idea.new("title"       => "dinner",
                    "description" => "chicken BBQ",
                    "id"          => '0',
                    "updated_at"   => '2013-10-17 16:42:53 -0600')
    new_data = {"title"       => "lunch",
                    "description" => "beef BBQ",
                    "id"          => "1"}
    result = idea1.merge(new_data)
    assert_equal "lunch", result.title
    assert_equal "beef BBQ", result.description
    refute_equal '2013-10-17 16:42:53 -0600', result.updated_at
  end
end
