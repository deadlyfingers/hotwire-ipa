# Hotwire IPA

A time saving script which enables you to use a prebuilt *.ipa archive and repackage it with new files to test quicker on device.

## Usage
`sh hotwire-ipa.sh -f ~/Desktop/App.ipa -c \"iPhone Developer: Your Name (XXXXXXXXXX)\" -d \"www\" -p ~/Sites/www`

## Options
	-f <path>		path to *.ipa file
	-c <string>		valid certificate identity
	-d <dir>		dir to delete inside app
	-p <dir>		dir to copy in place
	-i				install as ipa - faster install time for app's with many files
	-q				no debugging
	-z				don't replace 'Payload' dir each time

## Prerequisites
Install **ios-deploy** using [Node.js](https://nodejs.org) package manager

`npm install -g ios-deploy`

Install **ideviceinstaller** using [Homebrew](http://brew.sh/)

`brew install ideviceinstaller`

## Creating the developer *.ipa archive
1. In Xcode select device
	
	![Select device](https://cloud.githubusercontent.com/assets/1880480/10481403/469e914a-7268-11e5-8e85-e67e221c8a9c.png)

2. Product > Archive
	
	![Archive](https://cloud.githubusercontent.com/assets/1880480/10481404/499dde64-7268-11e5-8b4c-74950565d140.png)

3. Export
	
	![Export](https://cloud.githubusercontent.com/assets/1880480/10481406/4b7fe1a0-7268-11e5-9d88-a87c5381cca5.png)

4. Save for Development
	
	![Save for development](https://cloud.githubusercontent.com/assets/1880480/10481409/4d1b84e2-7268-11e5-8828-61e711ba59f1.png)

5. Export app
	
	![Export app](https://cloud.githubusercontent.com/assets/1880480/10481411/4ed336a4-7268-11e5-802b-79c742e0eecb.png)

6. Bitcode options
	
	![Bitcode Options](https://cloud.githubusercontent.com/assets/1880480/10481413/503d1708-7268-11e5-87e5-9e324d1eb039.png)

7. Reveal *.ipa file in Finder
	
	![Bitcode Options](https://cloud.githubusercontent.com/assets/1880480/10481414/529e1754-7268-11e5-9e73-e7d5f29d52cc.png)


### Smallprint
Use this script at your own risk - but it works on my machine!