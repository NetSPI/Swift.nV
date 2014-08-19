class User
	include DataMapper::Resource
	property :id,			Serial
	property :fname,		String
	property :lname, 		String
	property :email,		String
	property :password_hash,String
	property :is_active,	Boolean
	property :created_at,	DateTime
	property :updated_at,	DateTime
	property :api_token,	String

	has n, :secrets

	def self.gen_api_token
		SecureRandom.uuid
	end

	def self.by_token(token)
		User.first(:api_token => token)
	end
end