require 'yaml/store'
require './lib/idea_box/idea'

class IdeaStore

  class << self

    def database
      @database ||= YAML::Store.new "db/ideabox"
    end

    def create(attributes)
      new_idea = Idea.new(attributes)
      database.transaction do |db|
        db["ideas"] ||= []
        db["ideas"].push(new_idea.data_hash)
      end
    end

    def raw_idea
      database.transaction {|db| db["ideas"] || []}
    end

    def all
      raw_idea.collect {|attributes| Idea.new(attributes)}
    end

    def destroy_database_contents
      database.transaction { |db| db["ideas"] = [] }
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

  end

end
