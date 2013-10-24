require './lib/app'

class IdeaStatistics

  def day_names
    ["Monday", "Tuesday", "Wednesday", "Thursday",
     "Friday", "Saturday", "Sunday"]
  end

  def by_day
    hash = day_names.each_with_object({}) do |day, hash|
      hash[day] = IdeaStore.all.select {|idea| (idea.time_parse =~ /#{day[0...3]}/i)}
    end
    hash
  end

  def time_values
    ['00', '01', '02', '03', '04', '05', '06', '07',
     '08', '09', '10', '11', '12', '13', '14', '15',
     '16', '17', '18', '19', '20', '21', '22', '23']
  end

  def by_hour
    hash = time_values.each_with_object({}) do |hour, hash|
      hash[hour] = IdeaStore.all.select {|idea| (idea.time_parse =~ / #{hour}:/)}
    end
    hash
  end

  def best_days
    count = by_day.max_by {|k,v| v.count}.last.count
    by_day.select {|k,v| v.count == count}
  end

  def worst_days
    count = by_day.min_by {|k,v| v.count}.last.count
    by_day.select {|k,v| v.count == count}
  end

  def idea_count
    IdeaStore.all.count
  end

  def best_hours
    count = by_hour.max_by {|hour, ideas|  ideas.count}.last.count
    by_hour.select {|hour, ideas|  ideas.count == count}
  end

  def best_six_hours
    hours = best_hours.keys[0...6]
    best_hours.select {|hour, ideas| hours.include? hour}
  end

  def worst_hours
    count = by_hour.min_by {|hour, ideas|  ideas.count}.last.count
    by_hour.select {|hour, ideas|  ideas.count == count}
  end

  def worst_six_hours
    hours = worst_hours.keys[0...6]
    worst_hours.select {|hour, ideas| hours.include? hour}
  end

end
