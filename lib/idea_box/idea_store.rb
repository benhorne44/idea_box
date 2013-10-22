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
      new_idea = Idea.new(attributes)
      database.transaction do |db|
        db["ideas"] ||= []
        db["ideas"].push(new_idea.data_hash)
      end
      new_idea
    end

    def self.raw_ideas
      database.transaction {|db| db["ideas"] || []}
    end

    def self.all
      raw_ideas.collect.with_index do |attributes, index|
        Idea.new(attributes.merge("id" => index))
      end
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
      idea = Idea.new(raw_idea_for_id(id).merge("id" => id))
    end

    def self.update_like(id, new_data)
      old_idea = find(id)
      data_with_time_and_revisions = new_data.merge("updated_at" => Time.now, "revisions" => old_idea.revisions)
      new_idea = old_idea.data_hash.merge(data_with_time_and_revisions)
      database.transaction {database["ideas"][id] = new_idea}
    end

    def self.update(id, new_data)
      old_idea = find(id)
      old_idea.revisions << old_idea
      data_with_time_and_revisions = new_data.merge("updated_at" => Time.now, "revisions" => old_idea.revisions)
      new_idea = old_idea.data_hash.merge(data_with_time_and_revisions)
      database.transaction {database["ideas"][id] = new_idea}
    end

    def self.tag_hash
      all_tags_for_ideas.each_with_object({}) do |tag, hash|
        hash[tag] = all.select {|idea| idea.data_hash["tags"].include? tag}
      end
    end

    def self.all_tags_for_ideas
      all.collect {|idea| idea.data_hash["tags"].split(', ')}.flatten.uniq
    end

    def self.find_by_day(day)
      all.select {|idea| (idea.time_parse =~ /#{day}/)}
    end

    def self.day_values
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    end

    def self.time_values
      ['00', '01', '02', '03', '04', '05', '06', '07',
       '08', '09', '10', '11', '12', '13', '14', '15',
       '16', '17', '18', '19', '20', '21', '22', '23']
    end

    def self.find_by_time(time)
      all.select {|idea| (idea.time_parse =~ / #{time}:/)}
    end

    def self.find_by_day_and_time(day='', time='')
      day = find_by_day(day)
    end

    def self.search(phrase)
      all.select do |idea|
        (idea.title =~ /#{phrase}/i) ||
        (idea.description =~ /#{phrase}/i) ||
        (idea.data_hash["tags"] =~ /#{phrase}/i)
      end
    end

    def self.sort_by_created_at_date
      all.sort_by {|idea| idea.created_at}
    end

    def self.sort_by_day
      day_values.collect {|day| find_by_day(day) }.flatten
    end

    def self.sort_by_title
      all.sort_by {|idea| idea.title.downcase}
    end

    def self.sort_by_tag_count
      all.sort_by {|idea| idea.data_hash["tags"].split(', ').count}.reverse
    end

    def self.revisions(id)
      find(id).revisions
    end

end
