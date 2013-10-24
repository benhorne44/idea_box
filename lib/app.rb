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
    erb :"idea/edit", :locals => {idea: idea,
                           store: IdeaStore}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect "/#{id}/details"
  end

  get '/:id/details' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :"idea/idea_details", :locals => {idea: idea}
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update_like(id.to_i, idea.data_hash)
    redirect back
  end

  post '/:id/dislike' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.dislike!
    IdeaStore.update_dislike(id.to_i, idea.data_hash)
    redirect back
  end

  get '/tags/:tag' do
    tag_value = params[:tag]
    ideas_for_tags = IdeaStore.ideas_for_tags
    erb :tag_view, :locals => {tag_value: tag_value,
                               ideas_for_tags: ideas_for_tags}
  end

  get '/statistics/days/:day' do
    stats = IdeaStatistics.new
    ideas_for_day = stats.by_day.select {|day,ideas| (day =~ /#{params[:day]}/i)}
    erb :"idea/ideas_for_days", :locals => {stats: stats,
                                     day_name: params[:day],
                                     ideas_for_day: ideas_for_day}
  end

  get '/statistics/times/:time_value' do
    stats = IdeaStatistics.new
    ideas_for_time = stats.by_hour.select do |hour,ideas|
      (hour =~ /#{params[:time_value]}/)
    end
    time_value = params[:time_value]
    erb :"idea/ideas_for_times", :locals => {stats: stats,
                                             ideas_for_time: ideas_for_time,
                                             time_value: time_value}
  end

  get '/statistics' do
    stats = IdeaStatistics.new
    erb :"/statistics/statistics", :locals => {stats: stats}
  end

  get '/search/ideas' do
    ideas = IdeaStore.search(params[:search_value])
    erb :search, :locals => {search_ideas: ideas,
                             search: params[:search_value]}
  end



  get '/sort/:sort_by' do
    filtered = IdeaFilter.new(params[:sort_by])
    filtered_ideas = filtered.ideas
    param = filtered.param
    erb :"idea/sorted_ideas", :locals => {filtered_ideas: filtered_ideas,
                                          param: param}
  end

  get '/existing_ideas' do
    erb :"idea/existing_ideas", :locals => {ideas: IdeaStore.all.sort}
  end

  get '/groups/:group' do
    filtered = IdeaFilter.new(params[:group])
    ideas = filtered.by_group
    erb :groups, :locals => {ideas: ideas, group: params[:group]}
  end

  not_found do
    default_message = ''
    erb :error, :locals => {message: default_message}
  end

  helpers do

    def new_idea
      Idea.new
    end

    def all_idea_tags
      IdeaStore.all_tags_for_ideas.sort_by { |tag| tag.downcase }
    end

    def all_idea_groups
      IdeaStore.all_by_group.keys
    end

  end

end
