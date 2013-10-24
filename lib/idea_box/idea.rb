require 'time'
class Idea
  attr_reader :title, :id, :group, :description, :rank, :created_at
  attr_accessor :updated_at, :revisions, :tags

  def initialize(attributes = {})
    @title       = attributes["title"].to_s.strip
    @description = attributes["description"].to_s.strip
    @id          = attributes["id"]
    @created_at  = attributes["created_at"] ||= Time.now
    @updated_at  = attributes["updated_at"] ||= Time.now
    @rank        = attributes["rank"] || 0
    @tags        = attributes["tags"] || "no tag"
    @revisions   = attributes["revisions"] ||= []
    @group       = attributes["group"] || "default"
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
      "revisions"   => @revisions,
      "group"       => group
    }
  end

  def tags
    if @tags.class == Array
      @tags.sort.uniq
    else
      @tags.strip.split(', ').sort.uniq
    end
  end

  def tag_string
    tags.join(', ')
  end

  def time_parse
    Time.parse(created_at.to_s).rfc2822
  end

  def like!
    @rank += 1
  end

  def dislike!
    @rank -= 1
  end

  def <=>(other)
    other.rank <=> rank
  end

  def merge(new_data)
    revisions << self
    revisions.sort_by {|idea| idea.updated_at}
    data = new_data.merge("updated_at" => Time.now)
    Idea.new(data_hash.merge(data))
  end

end
