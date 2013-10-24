ENV['RACK_ENV'] = 'test'
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_box/statistics'

class IdeaStatisticsTest < Minitest::Test

    attr_reader :stats

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
    @stats = IdeaStatistics.new
  end

  def teardown
    IdeaStore.destroy_database_contents
  end

  def test_it_exists
    assert IdeaStatistics
  end

  def test_it_has_ideas_grouped_by_day
    ideas = stats.by_day
    assert_equal 7, stats.by_day.count
    assert_equal "Monday", stats.by_day["Monday"].first.title
    assert_equal "Tuesday", stats.by_day["Tuesday"].first.title
    assert_equal "Wednesday", stats.by_day["Wednesday"].first.title
    assert_equal "Thursday", stats.by_day["Thursday"].first.title
    assert_equal "Friday", stats.by_day["Friday"].first.title
    assert_equal "Saturday", stats.by_day["Saturday"].first.title
    assert_equal 2, stats.by_day["Sunday"].count
  end

  def test_it_can_find_all_ideas_for_a_day
    monday = stats.by_day["Monday"]
    assert_equal 1, monday.count
    assert_equal "Monday", monday.first.title
  end

  def test_it_has_ideas_grouped_by_time_of_day
    assert_equal 24, stats.by_hour.count
    assert_equal 2, stats.by_hour['12'].count
    assert_equal "Thursday", stats.by_hour['12'].first.title
    assert_equal 1, stats.by_hour['03'].count
    assert_equal "Wednesday", stats.by_hour['03'].first.title
  end

  def test_best_day_gives_day_with_highest_idea_count
    best_days = stats.best_days
    assert_equal "Sunday", best_days.keys.first
    assert_equal 2, best_days.values.first.count
  end

  def test_best_day_gives_days_with_highest_idea_count
    IdeaStore.create("title" => "Saturday",
                     "description" => "Partner",
                     "created_at" => "2013-10-19 14:04:25 -0600")
    assert_equal ["Saturday", "Sunday"], stats.best_days.keys
  end

  def test_worst_day_gives_days_with_lowest_idea_count
    assert_equal 6, stats.worst_days.count
    refute stats.worst_days.include? "Sunday"
  end

  def test_it_calculates_all_ideas_in_the_idea_store
    assert_equal 8, stats.idea_count
  end

  def test_it_has_best_hours
    assert_equal 1, stats.best_hours.count
    assert_equal '12', stats.best_hours.keys.first
  end

  def test_it_has_at_most_six_worst_hours
    assert_equal 17, stats.worst_hours.count
    assert_equal 6, stats.worst_six_hours.count
  end

   def test_it_has_at_most_six_best_hours
    assert_equal 1, stats.best_hours.count
    assert_equal 1, stats.best_six_hours.count
  end


end
