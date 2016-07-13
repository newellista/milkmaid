require "sinatra/base"

class MyApp < Sinatra::Base

  get '/' do
    'Milkmaid running'
  end

  run! if app_file == $0
end
