class IdeaFilter

    attr_reader :sort_by

    def initialize(sort_by)
      @sort_by = sort_by
    end

    def ideas
      if sort_by == 'title'
        IdeaStore.sort_by_title
      elsif sort_by == 'day'
        IdeaStore.sort_by_day
      elsif sort_by == 'time'
        IdeaStore.sort_by_created_at_date
      elsif sort_by == 'tag_count'
        IdeaStore.sort_by_tag_count
      end
    end

    def param
      if sort_by == 'title'
        'title'
      elsif sort_by == 'day'
        'day'
      elsif sort_by == 'time'
        'date created'
      elsif sort_by == 'tag_count'
        'tag count'
      end
    end

    def by_group
      if sort_by == 'all'
        IdeaStore.all
      else
        IdeaStore.all_by_group[sort_by]
      end
    end

  end
