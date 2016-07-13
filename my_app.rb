require "sinatra/base"

class MyApp < Sinatra::Base

  get '/' do
    'Milkmaid running'
  end
end
