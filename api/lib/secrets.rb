class Secret
	include DataMapper::Resource
	property :id,			Serial
	property :name,			String
	property :contents, 	String
	property :version,		Integer
	property :checksum,		String
	property :status,		String
	property :root_id,		Integer
	belongs_to	:user
end

# Fetch single secret by id
get '/secret/:id' do
	secret = Secret.get(params[:id])
	if secret
		secret.to_json
	else
		{ :error => "Secret with that id does not exist" }.to_json
	end
end

get '/secret/:root_id/current_version' do
	Secret.last(:root_id => params[:root_id]).to_json
end

# Fetch all secrets for user
get '/secrets' do
	current_user.secrets.to_json
end

# Create new secret
post '/secret' do
	params = MultiJson.load(request.body.read)
	secret = Secret.new(params)
	secret.user = current_user
	if secret.save
		secret.root_id = secret.id
		secret.save
		secret.to_json
	else
		MultiJson.dump({ :error => "Error creating secret" })
	end
end

put '/secret/:secret_id' do
	# Check if secret exists, first
	if Secret.get(params[:secret_id])
		# How do we want to handle updates?
		# Create new object, disassociate previous object?
		old_secret = Secret.get(params[:secret_id])
		old_secret.status = "old"
		old_secret.save

		json_params = MultiJson.load(request.body.read)

		new_secret = Secret.new
		new_secret.name = json_params["name"]
		new_secret.contents = json_params["contents"]
		new_secret.checksum = json_params["checksum"]
		new_secret.version = old_secret.version + 1
		new_secret.user = current_user
		new_secret.root_id = old_secret.root_id || old_secret.id

		if new_secret.save
			new_secret.to_json
		else
			MultiJson.dump({ :error => "Cannot update secret"})
		end
	else
		MultiJson.dump({ :error => "Cannot find secret with id: #{params[:id]}"})
	end
end

delete '/secret/:secret_id' do
	secret = Secret.get(params[:secret_id])
	if secret
		secret.destroy
		MultiJson.dump({ :success => "Successfully destroyed secret" })
	else
		MultiJson.dump({ :error => "Unable to destroy secret" })
	end
end