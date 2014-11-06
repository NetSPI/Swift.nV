Swift.nV
==========

Swift.nV is a vulnerable iOS "secret keeper" application. It is intended as a security training tool instructing Swift developers on common mobile application vulnerabilities, how they are found, and how to prevent them.

Setup
-----

Swift.nV has currently been tested using:

	XCode 6 beta7
	iOS Simulator 
		- iPhone 4/5/5s
		- iPad 2/Air/Retina
		- iOS 8.0
	Ruby + Sinatra (for the backend web service)
		Required Ruby Gems:
		- sinatra, dm-core, dm-timestamps, dm-migrations, dm-serializer, bcrypt


Run
---
	- Open up the Swift.nV.xcodeproj using XCode 6 beta6
	- Start the Sinatra backend web service:
		- In the api directory run "bundle install" this will install the needed gems	
		- In the api directory run "ruby api.rb"
		- This service should run on localhost (127.0.0.1) port 4567
	- Click the Run icon after selecting one of the iOS Simulator targets
	- If the build fails with linker errors, remove the Swift.nV-* directories in ~/Library/Developer/Xcode/DerivedData

Use
---
	- Click 'register' on the initial log on screen to setup a user.
	- Login with the registered user
	- Add secrets

Tutorials
---------
	- Located within the API at http://localhost:4567/tutorial

Explore
-------
	- View the simulator data storage under:
		- ~/Library/Developer/CoreSimulator/Devices/<Device-ID>/data/Containers/Data/Application/<Application-ID>/Documents
		- ~/Library/Developer/CoreSimulator/Devices/<Device-ID>/data/Library/Preferences/

Intentional Vulnerabilities
---------------------------
Not all vulnerabilities have associated tutorials. View the tutorial list included at http://localhost:4567/tutorial for a walk through.

	- Weak Server Side Controls (M1) - Backend web service is vulnerable to forced browsing.
	- Weak Server Side Controls (M1) - Backend web service is vulnerable to authentication bypass.
	- Insecure Data Storage (M2) - Core Data stores all items in the local sqlite database.
	- Insecure Data Storage (M2) - Username/email address is in the user preferences plist file.
	- Insufficient Transport Layer Protection (M3) - No SSL for backend web service.
	- Unintended Data Leakage (M4) - No protections of automatic iOS background screenshots.
	- Unintended Data Leakage (M4) - Log contains multiple sensitive strings.
	- Unintended Data Leakage (M4) - Autocomplete is not enabled on sensitive screens (secret entry).
	- Unintended Data Leakage (M4) - Login form is not cleared upone successful login.
	- Poor Authorization and Authentication (M5) - Changes to insecure stored data (email address) bypasses authentication.
	- Poor Authorization and Authentication (M5) - Same email address can be registered multiple times, allowing a user to view another's secrets.
	- Broken Cryptography (M6) - Shared Secret "CryptoKey" is stored within the Environment.plist file.
	- Client Side Injection (M7) - multiple locations, including Format String Injection on the login screen.
	- Improper Session Handling (M8) - App completely lacks any session tokens or they are unused for interaction with API.
