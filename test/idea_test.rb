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

  def test_the_like_method_updates_database

  end

  def test_it_has_a_data_hash_with_data_passed_in
    idea = Idea.new("title"       => "dinner",
                    "description" => "chicken BBQ" )
    expected = { "title"       => "dinner",
                 "description" => "chicken BBQ",
                 "rank"       => 0,
                 "tags"        => [] }
    assert_equal expected, idea.data_hash
    idea.like!
    expected = {  "title"       => "dinner",
                  "description" => "chicken BBQ",
                  "rank"        => 1,
                  "tags"        => []}
    assert_equal expected, idea.data_hash
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

  def test_an_idea_has_no_tags_by_default
    idea = Idea.new
    assert_equal [], idea.tags
  end

  def test_it_can_add_a_tag
    idea = Idea.new
  end
end
