def current_user
	# Get api-token from request
	apitoken = params[:apitoken]

	unless apitoken.nil?
		User.by_token(apitoken)
	else
		User.new
	end
end