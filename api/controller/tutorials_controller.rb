Tilt.register Tilt::ERBTemplate, 'html.erb'

helpers do

  def partial(template)
    erb template, :layout => false
  end

end

get '/tutorial' do
  erb :index
end