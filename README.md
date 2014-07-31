Swift.nV
==========

Swift.nV is a vulnerable iOS "secret keeper" application.

More information about Swift.nV and its vulnerabilities can be found [here](https://github.com/nVisium/Swift.nV/wiki)

Setup
-----

Swift.nV has currently been tested using:

	- XCode 6 beta4
	- iPhone Simulator 
		- iPhone 5/5s
		- iOS 8.0
	- Ruby + Sinatra (for the backend web service)


Run
---
	- Open up the Swift.nV.xcodeproj using XCode 6 beta4
	- Start the Sinatra backend web service:
		- In the api directory run "ruby api.rb"
		- This service should run on localhost (127.0.0.1) port 4567
	- Click the Run icon after selecting one of the iPhone Simulator targets

Use
---
	- Click 'register' on the initial log on screen to setup a user.
	- Login with the registered user
	- Add secrets

Known Vulnerabilities
---------------------
	- Stored Data - Core Data stores all items in the local sqlite database
	- Stored Data - Username/email address is in the user preferences plist file
	- Encryption - CryptoKey is stored within the Environment.plist file
	- Encryption - No SSL encryption to the web service
