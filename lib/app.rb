require 'sinatra/base'
require './lib/ideabox'



class IdeaBoxApp < Sinatra::Base

  set :method_override, true
  set :root, 'lib/app'

  get '/' do
    erb :index
  end

  post '/' do
    IdeaStore.create(params[:idea])
    redirect back
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect back
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, :locals => {idea: idea,
                           store: IdeaStore}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect "/#{id}/details"
  end

  get '/:id/details' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :idea_details, :locals => {idea: idea}
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update_like(id.to_i, idea.data_hash)
    redirect back
  end

  not_found do
    erb :error
  end

  get '/tags/:tag' do
    tag_value = params[:tag]
    ideas_for_tags = IdeaStore.ideas_for_tags
    erb :tag_view, :locals => {tag_value: tag_value,
                               ideas_for_tags: ideas_for_tags}
  end

  get '/statistics/days/:day' do
    stats = IdeaStatistics.new
    ideas_for_day = stats.by_day.select {|day,ideas| (day =~ /#{params[:day]}/)}
    erb :ideas_for_days, :locals => {stats: stats,
                                     day_name: params[:day],
                                     ideas_for_day: ideas_for_day}
  end

  get '/statistics/times/:time_value' do
    stats = IdeaStatistics.new
    ideas_for_time = stats.by_hour.select do |hour,ideas|
      (hour =~ /#{params[:time_value]}/)
    end
    time_value = params[:time_value]
    ideas = IdeaStore.find_by_time(params[:time_value])
    erb :ideas_for_times, :locals => {stats: stats,
                                      ideas_for_time: ideas_for_time,
                                      time_value: time_value}
  end

  get '/search/ideas' do
    ideas = IdeaStore.search(params[:search_value])
    erb :search, :locals => {search_ideas: ideas,
                             search: params[:search_value]}
  end

  get '/statistics' do
    stats = IdeaStatistics.new
    sorted_ideas = IdeaStore.all.sort_by {|idea| idea.created_at}
    # max_idea_day = store.day_names.max_by{|day| store.find_by_day(day[0...3]).count }
    # min_idea_day = "something"
    # total_idea_count = { "Mon" => 1 }

    # erb :statistics, :locals => { max_idea_day: stats.max_idea_day, min_idea_day: stats.min_idea_day, total_idea_count: stats.total_idea_count}
    # erb :statistics, :locals => { stats: stats }
    erb :statistics, :locals => {stats: stats, store: IdeaStore, sorted_ideas: sorted_ideas}
  end

  class IdeaFilter
    def initialize(sort_by)
      @sort_by = sort_by
    end

    attr_reader :sort_by

    def ideas
      if sort_by == 'title'
        IdeaStore.sort_by_title
      elsif sort_by == 'day'
        IdeaStore.sort_by_day
      elsif sort_by == 'time'
        IdeaStore.sort_by_created_at_date
      elsif sort_by == 'tag'
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
      elsif sort_by == 'tag'
        'tag count'
      end
    end
  end

  get '/sort/:sort_by' do
    ideas_filtered = IdeaFilter.new(params[:sort_by])
    ideas = ideas_filtered.ideas
    param = ideas_filtered.param
    erb :sorted_ideas, :locals => {ideas: ideas, param: param}
  end

  get '/existing_ideas' do
    erb :existing_ideas, :locals => {ideas: IdeaStore.all.sort}
  end

  helpers do
    def new_idea
      Idea.new
    end

    def all_idea_tags
      IdeaStore.all_tags_for_ideas
    end

  end

end
