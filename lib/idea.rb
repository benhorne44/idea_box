require './lib/idea_store'
class Idea
  attr_reader :title, :description, :id, :rank

  def initialize(attributes = {})
    @title = attributes["title"]
    @description = attributes["description"]
    @id = attributes["id"]
    @rank = attributes["rank"] || 0
  end

  def data_hash
    {
      "title" => title,
      "description" => description,
      "rank" => rank
    }
  end

  def like!
    @rank += 1
    IdeaStore.update(id.to_i, "title" => title,
                         "description" => description,
                         "rank" => rank)
  end

  def <=>(other)
    other.rank <=> rank
  end
end
