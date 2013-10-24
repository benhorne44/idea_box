require 'yaml/store'
require './lib/idea_box/idea'

class IdeaStore

    def self.database
      if ENV['RACK_ENV'] == 'test'
        @database ||= YAML::Store.new "db/test/ideabox"
      else
        @database_test ||= YAML::Store.new "db/ideabox"
      end
    end

    def self.create(attributes)
      new_idea = Idea.new(attributes.merge("id" => all.count))
      database.transaction do |db|
        db["ideas"] ||= []
        db["ideas"] << new_idea.data_hash
      end
      new_idea
    end

     def self.all
      raw_ideas.collect.with_index do |attributes, index|
        Idea.new(attributes.merge("id" => index))
      end
    end

    def self.raw_ideas
      database.transaction {|db| db["ideas"] || []}
    end

    def self.destroy_database_contents
      database.transaction { |db| db["ideas"] = nil}
    end

    def self.delete(position)
      database.transaction {database["ideas"].delete_at(position)}
    end

    def self.raw_idea_for_id(id)
      database.transaction {database["ideas"].at(id)}
    end

    def self.find(id)
      Idea.new(raw_idea_for_id(id).merge("id" => id))
    end

    def self.find_by_day(day)
      all.select {|idea| (idea.time_parse =~ /#{day}/i)}
    end

    def self.find_by_time(time)
      all.select {|idea| (idea.time_parse =~ / #{time}:/)}
    end

    def self.search(phrase)
      all.select do |idea|
        (idea.title =~ /#{phrase}/i) ||
        (idea.description =~ /#{phrase}/i) ||
        (idea.data_hash["tags"] =~ /#{phrase}/i)
      end
    end

    def self.update_like(id, new_data)
      old_idea = find(id)
      old_idea.like!
      database.transaction {database["ideas"][id] = old_idea.data_hash}
    end

    def self.update_dislike(id, new_data)
      old_idea = find(id)
      old_idea.dislike!
      database.transaction {database["ideas"][id] = old_idea.data_hash}
    end

    def self.update(id, new_data)
      new_idea = find(id).merge(new_data)
      database.transaction {database["ideas"][id] = new_idea.data_hash}
    end

    def self.ideas_for_tags
      all_tags_for_ideas.each_with_object({}) do |tag, hash|
        hash[tag] = all.select {|idea| idea.tags.include? tag}
      end
    end

    def self.all_tags_for_ideas
      all.collect {|idea| idea.tags}.flatten.uniq.sort
    end

    def self.day_values
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    end

    def self.sort_by_created_at_date
      all.sort_by {|idea| idea.created_at}
    end

    def self.sort_by_day
      day_values.collect {|day| find_by_day(day) }.flatten
    end

    def self.sort_by_title
      grouped = all.group_by {|idea| idea.title.downcase}
      grouped.sort_by {|title,ideas| title}
    end

    def self.sort_by_tag_count
      all.sort_by {|idea| idea.tags.count}.reverse
    end

end
