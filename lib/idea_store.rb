require 'yaml/store'
require './lib/idea'

class IdeaStore

  class << self

    def database
      @database ||= YAML::Store.new "db/ideabox"
    end

    def create(attributes)
      database.transaction do |db|
        db["ideas"] ||= []
        db["ideas"].push(attributes)
      end
    end

    def idea_data
      database.transaction {|db| db["ideas"] || []}
    end

    def all
      idea_data.collect {|attributes| Idea.new(attributes)}
    end

    def destroy_database_contents
      database.transaction { |db| db["ideas"] = [] }
    end

    def delete(position)
      database.transaction {database["ideas"].delete_at(position)}
    end

    def idea_data_for_id(id)
      database.transaction {database["ideas"].at(id)}
    end

    def find(id)
      Idea.new(idea_data_for_id(id).merge("id" => id))
    end

    def update(id, new_data)
      database.transaction {database["ideas"][id] = new_data}
    end

  end

end
