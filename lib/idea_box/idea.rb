
class Idea
  include Comparable

  attr_reader :title, :description, :attributes, :rank, :id

  def initialize(attributes = {})
    @attributes = attributes
    @title = attributes["title"]
    @description = attributes["description"]
    @rank = attributes["rank"] || 0
    @id = attributes["id"]
  end

  def save
    IdeaStore.create(data_hash)
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
  end

  def <=>(other)
    other.rank <=> rank
  end

end
