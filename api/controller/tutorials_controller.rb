Tilt.register Tilt::ERBTemplate, 'html.erb'

helpers do

  def partial(template)
    erb template, :layout => false
  end

end

get '/tutorial' do
  erb :index
end

get '/tutorial/m1' do
   erb 'tutorials/m1'.to_sym
end

get '/tutorial/m2' do
   erb 'tutorials/m2'.to_sym
end

get '/tutorial/m3' do
   erb 'tutorials/m3'.to_sym
end

get '/tutorial/m4' do
   erb 'tutorials/m4'.to_sym
end

get '/tutorial/m5' do
   erb 'tutorials/m5'.to_sym
end

get '/tutorial/m6' do
   erb 'tutorials/m6'.to_sym
end

get '/tutorial/m7' do
   erb 'tutorials/m7'.to_sym
end

get '/tutorial/m8' do
   erb 'tutorials/m8'.to_sym
end

get '/tutorial/m9' do
   erb 'tutorials/m9'.to_sym
end

get '/tutorial/m10' do
   erb 'tutorials/m10'.to_sym
end