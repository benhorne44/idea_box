require 'sinatra/base'
require './lib/idea_box/idea'
require './lib/idea_box/idea_store'



class IdeaBoxApp < Sinatra::Base

  set :method_override, true
  set :root, 'lib/app'

  # configure :development do
  #   register Sinatra::Reloader
  # end

  get '/' do
    erb :index, :locals => {ideas: IdeaStore.all.sort,
                            idea: Idea.new,
                            store: IdeaStore}
  end

  post '/' do
    IdeaStore.create(params[:idea])
    redirect '/existing_ideas'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/existing_ideas'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, :locals => {idea: idea,
                           store: IdeaStore}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect '/existing_ideas'
  end

  get '/:id/details' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :idea_details, :locals => {idea: idea}
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.data_hash)
    redirect '/existing_ideas'
  end

  not_found do
    erb :error
  end

  get '/tags/:tag' do
    erb :tag_view, :locals => {ideas: IdeaStore,
                               tag: params[:tag]}
  end

  get '/search/days/:search_value' do
    search_value = params[:search_value]
    ideas = IdeaStore.find_by_day(search_value)
    erb :ideas_for_days, :locals => {ideas: ideas,
                                     search: search_value,
                                     store: IdeaStore}
  end

  get '/search/times/:search_value' do
    search_value = params[:search_value]
    ideas = IdeaStore.find_by_time(params[:search_value])
    erb :ideas_for_times, :locals => {ideas: ideas, search: search_value, store: IdeaStore}
  end

  get '/search/ideas' do
    ideas = IdeaStore.search(params[:search_value])
    erb :search, :locals => {search_ideas: ideas, search: params[:search_value]}
  end

  get '/statistics' do
    erb :statistics, :locals => {store: IdeaStore}
  end

  get '/sort/:sort_by' do
    if params[:sort_by] == 'title'
      ideas = IdeaStore.sort_by_title
      param = 'title'
    elsif params[:sort_by] == 'day'
      ideas = IdeaStore.sort_by_day
      param = 'day'
    elsif params[:sort_by] == 'time'
      ideas = IdeaStore.sort_by_created_at_date
      param = 'date created'
    elsif params[:sort_by] == 'tag'
      ideas = IdeaStore.sort_by_tag_count
      param = 'tag count'
    end
    erb :sorted_ideas, :locals => {ideas: ideas, param: param}

  end

  get '/existing_ideas' do
    erb :existing_ideas, :locals => {ideas: IdeaStore.all.sort}
  end

  helpers do
    def new_idea
      Idea.new
    end
  end

end
