require 'time'
class Idea
  attr_reader :title, :id, :description, :rank, :created_at
  attr_accessor :updated_at

  def initialize(attributes = {})
    @title       = attributes["title"]
    @description = attributes["description"]
    @id          = attributes["id"]
    @created_at  = attributes["created_at"] ||= Time.now
    @updated_at  = attributes["updated_at"] = Time.now
    @rank        = attributes["rank"] || 0
    @tags        = attributes["tags"] || "no tag"
  end

  def data_hash
    {
      "title"       => title,
      "description" => description,
      "rank"        => rank,
      "tags"        => @tags,
      "created_at"  => created_at,
      "updated_at"  => updated_at
    }
  end

  def time_parse
    Time.parse(created_at.to_s).rfc2822
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    other.rank <=> rank
  end


end
