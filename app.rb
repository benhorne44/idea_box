require './idea'

class IdeaBoxApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb :index, :locals => {ideas: something}
  end

  post '/' do
    idea = Idea.new(params[:idea_title], params[:idea_description])
    idea.save
    redirect '/'
  end

  not_found do
    erb :error
  end
end
