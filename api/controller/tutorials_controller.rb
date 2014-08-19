Tilt.register Tilt::ERBTemplate, 'html.erb'

require 'erb'

get '/tutorial' do
  erb :index
end