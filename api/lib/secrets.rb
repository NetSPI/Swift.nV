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

get '/create/secret' do
	secret = Secret.new
	secret.name = "John's Secret"
	secret.contents = "UmVhbGx5IHNlY3VyZSBzdHVmZiBsb2w="
	secret.checksum = "f619872ec8f3747098835fa4e591fe03"
	secret.version = 1
	secret.user = current_user
	secret.save
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

# Fetch all secrets for user
get '/secrets' do
	current_user.secrets.to_json
end

# Create new secret
post '/secret' do
	params = JSON.parse(request.body.read)
	secret = Secret.new(params)
	secret.user = current_user
	if secret.save
		secret.to_json
	else
		{ :error => "Error creating secret" }
	end
end

put '/secret/:id' do
	# Check if secret exists, first
	if Secret.get(params[:id])
		# How do we want to handle updates?
		# Create new object, disassociate previous object?
		old_secret = Secret.get(params[:id])
		old_secret.status = "old"
		old_secret.save

		new_secret = Secret.new
		new_secret.name = params[:name]
		new_secret.contents = params[:contents]
		new_secret.checksum = params[:checksum]
		new_secret.version = old_secret.version + 1
		new_secret.user = current_user
		new_secret.root_id = old_secret.root_id || old_secret.id
		
		if new_secret.save
			new_secret.to_json
		else
			{ :error => "Cannot update secret"}
		end
	else
		{ :error => "Cannot find secret with id: #{params[:id]}"}
	end
end