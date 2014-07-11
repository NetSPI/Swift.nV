require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'json'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/api.db")

class User
	include DataMapper::Resource
	property :id,			Serial
	property :fname,		String
	property :lname, 		String
	property :email,		String
	property :is_active,	Boolean
	property :created_at,	DateTime
	property :updated_at,	DateTime
	property :api_token,	String

	def self.gen_api_token
		SecureRandom.uuid
	end
end

before do
	headers "Content-Type" => "application/json; charset=utf-8"	
end

# load all libraries
configure do
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| 
    require File.basename(lib, '.*') 
  }
end

# Helper method to convert objects to json
def jsonify(obj)
	obj.attributes.to_json
end

DataMapper.auto_upgrade!