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
                            idea: Idea.new}
  end

  post '/' do
    IdeaStore.create(params[:idea])
    redirect '/'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, :locals => {idea: idea,
                           store: IdeaStore}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.data_hash)
    redirect '/'
  end

  not_found do
    erb :error
  end

  get '/tags/:tag' do
    erb :tag_view, :locals => {ideas: IdeaStore,
                               tag: params[:tag]}
  end

  get '/new_idea' do
    erb :new_idea, :locals => {idea: Idea.new}
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

  get '/statistics' do
    erb :statistics, :locals => {store: IdeaStore}
  end

end
