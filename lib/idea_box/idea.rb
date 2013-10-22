require 'time'
class Idea
  attr_reader :title, :id, :description, :rank, :created_at
  attr_accessor :updated_at, :revisions, :tags

  def initialize(attributes = {})
    @title       = attributes["title"]
    @description = attributes["description"]
    @id          = attributes["id"]
    @created_at  = attributes["created_at"] ||= Time.now
    @updated_at  = attributes["updated_at"] ||= Time.now
    @rank        = attributes["rank"] || 0
    @tags        = attributes["tags"] || "no tag"
    @revisions   = attributes["revisions"] ||= []
  end

  def data_hash
    {
      "title"       => title,
      "id"          => id,
      "description" => description,
      "rank"        => rank,
      "tags"        => tags,
      "created_at"  => created_at,
      "updated_at"  => updated_at,
      "revisions"   => @revisions
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

  def merge(new_data)
    revisions << self
    data = new_data.merge("updated_at" => Time.now)
    Idea.new(data_hash.merge(data))
  end

end
