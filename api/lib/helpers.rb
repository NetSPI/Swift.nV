helpers do
  def request_headers
    env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
  end  
end

def current_user
	# Get api-token from header and return user object
	apitoken = params[:apitoken]
	User.by_token(apitoken)
end