class Secret
	include DataMapper::Resource
	property :id,			Serial
	property :name,			String
	property :contents, 		String
	property :notes,		String
	property :version,		Integer
	property :checksum,		String
	property :status,		String
	property :root_id,		Integer
	belongs_to	:user
end