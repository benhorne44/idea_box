gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea.rb'

class IdeaTest < Minitest::Test
  def test_basic_idea
    idea = Idea.new("title"       => "dinner",
                    "description" => "chicken BBQ",
                    "id"          => "1")
    assert_equal "dinner", idea.title
    assert_equal "chicken BBQ", idea.description
    assert_equal "1", idea.id
  end

  def test_it_has_a_data_hash_with_data_passed_in
    idea = Idea.new("title"       => "dinner",
                    "description" => "chicken BBQ",
                    "id"          => "1")
    expected = {    "title"       => "dinner",
                    "description" => "chicken BBQ",
                    "votes"       => 0 }
    assert_equal expected, idea.data_hash
    idea.like!
    expected2 = {   "title"       => "dinner",
                    "description" => "chicken BBQ",
                    "votes"       => 1 }
    assert_equal expected2, idea.data_hash
  end

  def test_it_gets_a_votes_of_0_initially
    idea = Idea.new
    assert_equal 0, idea.votes
  end

  def test_like_method_raises_the_vote_count
    idea = Idea.new
    assert_equal 0, idea.votes
    idea.like!
    assert_equal 1, idea.votes
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
end
