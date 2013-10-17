

class Idea
  attr_reader :title, :id, :description, :rank
  attr_accessor :tags

  def initialize(attributes = {})
    @title = attributes["title"]
    @description = attributes["description"]
    @id = attributes["id"]
    @rank = attributes["rank"] || 0
    @tags = attributes["tags"] || []
  end

  def data_hash
    {
      "title"       => title,
      "description" => description,
      "rank"        => rank,

      "tags"        => tags
    }
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    other.rank <=> rank
  end
end
