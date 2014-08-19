
post '/users/register' do
  params = MultiJson.load(request.body.read)

  password_hash = BCrypt::Password.create(params["password"])
  # Remove password value because it's not an attribute of user
  params.delete("password")

  @user = User.new(params)
  @user.password_hash = password_hash

  if @user.save
  	@user.to_json
  else
  	MultiJson.dump({ :error => "Error creating user." })
  end
end

# Authenticate by email and password
post '/users/authenticate' do
	params = MultiJson.load(request.body.read)
	email = params["email"]
	password = params["password"]

	possible_user = User.first(:email => email)

	if possible_user
		if BCrypt::Password.new(possible_user.password_hash) == password
			possible_user.api_token = User.gen_api_token
			possible_user.save
			possible_user.to_json
		else
			MultiJson.dump({ :error => "Password not valid for user: #{email}" })
		end
	else
		MultiJson.dump({ :error => "Could not find user: #{email}" })
	end
end

get '/user/:id' do
	@user = User.get(params[:id])
	if @user
		@user.to_json
	else
		MultiJson.dump({ :error => "User with that id does not exist" })
	end
end

# Not working, wtf
post '/user/logout' do
	current_user.api_token = nil
	current_user.save
end