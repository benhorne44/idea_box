require 'yaml/store'
require './lib/idea_box/idea'

class IdeaStore

  class << self

    def database
      if ENV['RACK_ENV'] == 'test'
        @database ||= YAML::Store.new "db/test/ideabox"
      else
        @database_test ||= YAML::Store.new "db/ideabox"
      end
    end

    def create(attributes)
      new_idea = Idea.new(attributes)
      database.transaction do |db|
        db["ideas"] ||= []
        db["ideas"].push(new_idea.data_hash)
      end
    end

    def raw_ideas
      database.transaction {|db| db["ideas"] || []}
    end

    def all
      raw_ideas.each_with_index.collect do |attributes, index|
        Idea.new(attributes.merge("id" => index))
      end
    end

    def destroy_database_contents
      database.transaction { |db| db["ideas"] = nil}
    end

    def delete(position)
      database.transaction {database["ideas"].delete_at(position)}
    end

    def raw_idea_for_id(id)
      database.transaction {database["ideas"].at(id)}
    end

    def find(id)
      idea = Idea.new(raw_idea_for_id(id).merge("id" => id))
    end

    def update(id, new_data)
      old_idea = find(id)
      new_idea = old_idea.data_hash.merge(new_data)
      database.transaction {database["ideas"][id] = new_idea}
    end

    def tag_hash
      all_tags_for_ideas.each_with_object({}) do |tag, hash|
        hash[tag] = all.select {|idea| idea.data_hash["tags"].include? tag}
      end
    end

    def all_tags_for_ideas
      all.collect {|idea| idea.data_hash["tags"].split(', ')}.flatten.uniq
    end

  end

end
