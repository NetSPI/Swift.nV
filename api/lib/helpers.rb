def current_user
	# Get api-token from header and return user object
	apitoken = params[:apitoken]
	User.by_token(apitoken)
end