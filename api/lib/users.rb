post '/users/register' do
  params = JSON.parse(request.body.read)
  @user = User.new(params)
  @user.api_token = User.gen_api_token

  if @user.save
  	jsonify(@user)
  else
  	{ :error => "Error creating user." }.to_json
  end
end

# Seed Data
get '/create/admin' do
	adm = User.new
	adm.fname = "john"
	adm.lname = "poulin"
	adm.email = "john.m.poulin@gmail.com"
	adm.is_active = true
	adm.save
end

post '/users/authenticate' do
	params = JSON.parse(request.body.read)
end

get '/users/find/:id' do
	@user = User.get(params[:id])
	if @user
		jsonify(@user)
	else
		{ :error => "User with that id does not exist" }.to_json
	end
end