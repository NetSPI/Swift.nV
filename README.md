Swift.nV
==========

Swift.nV is a vulnerable iOS "secret keeper" application.

More information about Swift.nV and its vulnerabilities can be found [here](https://github.com/nVisium/Swift.nV/wiki)

Setup
-----

Swift.nV has currently been tested using:

	- XCode 6 beta5
	- iPhone Simulutor 
		- iPhone 4/5/5s
		- iPad 2/Air
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

Explore
-------
	- View the simulator data storage under:
		- <Home Directory>/Library/Developer/CoreSimulator/Devices/<Device-ID>/data/Containers/Data/Application/<Application-ID>/Documents
		-  <Home Directory>/Library/Developer/CoreSimulator/Devices/<Device-ID>/data/Library/Preferences/

Intentional Vulnerabilities
---------------------------
	- Weak Server Side Controls (M1) - Backend web service is vulnerable to forced browsing.
	- Weak Server Side Controls (M1) - Backend web service is vulnerable to authentication bypass.
	- Insecure Data Storage (M2) - Core Data stores all items in the local sqlite database
	- Insecure Data Storage (M2) - Username/email address is in the user preferences plist file
	- Insufficient Transport Layer Protection (M3) - No SSL for backend web service.
	- Unintended Data Leakage (M4) - No protections of automatic iOS background screenshots
	- Unintended Data Leakage (M4) - Log contains multiple sensitive strings
	- Unintended Data Leakage (M4) - Autocomplete is not enabled on sensitive screens (secret entry).
	- Poor Authorization and Authentication (M5) - Changes to insecure stored data (email address) bypasses authentication.
	- Poor Authorization and Authentication (M5) - Same email address can be registered multiple times, allowing a user to view another's secrets.
	- Broken Cryptography (M6) - Shared Secret "CryptoKey" is stored within the Environment.plist file
	- Client Side Injection (M7) - multiple locations, including Format String Injection on the login screen
