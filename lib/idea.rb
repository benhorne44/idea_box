class Idea
  attr_reader :title, :description, :id, :votes

  def initialize(attributes = {})
    @title = attributes["title"]
    @description = attributes["description"]
    @id = attributes["id"]
    @rank = 0
  end

  def data_hash
    {"title" => title,
     "description" => description,
     "rank" => rank}
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    other.rank <=> rank
  end
end
