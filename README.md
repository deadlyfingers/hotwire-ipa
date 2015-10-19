# Hotwire IPA

A time saving script which enables you to use a prebuilt \*.ipa archive and repackage it with new files to test quicker on device.

## Usage examples
`sh hotwire-ipa.sh -f ~/Desktop/App.ipa -d \"www\" -p ~/Sites/www`

`sh hotwire-ipa.sh -f ~/Desktop/App.ipa -c \"iPhone Developer: Your Name (XXXXXXXXXX)\" -d \"www\" -p ~/Sites/www -b ~/Cordova/app/platforms/ios/www -i`

## Options

params | arg | description
------ | --- | -----------
\-f | *path* | path to \*.ipa archive
\-d | *dir* | dir to delete inside app
\-p | *dir* | dir to copy in place
\-b | *dir* | dir to copy cordova build plugins and javascripts
\-c | *string* | valid certificate code sign identity
\-m | *path* | path to \*.mobileprovision profile

switches | description
-------- | -----------
\-i | install as \*.ipa (faster install time for an app with many files)
\-q | no debugging
\-z | reuse unzipped 'Payload' dir

## Prerequisites
Install **ios-deploy** using [Node.js](https://nodejs.org) package manager

`npm install -g ios-deploy`

Install **ideviceinstaller** using [Homebrew](http://brew.sh/)

`brew install ideviceinstaller`

NB: To enable automatic launch of \*.ipa to device you will also need to install
[idevice-app-runner](https://github.com/storoj/idevice-app-runner.git) and add it to your $PATH.

## Creating the developer \*.ipa archive
1. In Xcode select *Device* as build target

	![Select device](https://cloud.githubusercontent.com/assets/1880480/10481403/469e914a-7268-11e5-8e85-e67e221c8a9c.png)

2. Select Product > Archive

	![Archive](https://cloud.githubusercontent.com/assets/1880480/10481404/499dde64-7268-11e5-8b4c-74950565d140.png)

3. Click 'Export'

	![Export](https://cloud.githubusercontent.com/assets/1880480/10481406/4b7fe1a0-7268-11e5-9d88-a87c5381cca5.png)

4. Export options: 'Save for Development Deployment'

	![Save for development](https://cloud.githubusercontent.com/assets/1880480/10481409/4d1b84e2-7268-11e5-8828-61e711ba59f1.png)

5. Device support options

	![Export app](https://cloud.githubusercontent.com/assets/1880480/10481411/4ed336a4-7268-11e5-802b-79c742e0eecb.png)

6. Bitcode options

	![Bitcode Options](https://cloud.githubusercontent.com/assets/1880480/10481413/503d1708-7268-11e5-87e5-9e324d1eb039.png)

7. Reveal \*.ipa file in Finder

	![Bitcode Options](https://cloud.githubusercontent.com/assets/1880480/10481414/529e1754-7268-11e5-9e73-e7d5f29d52cc.png)


## Provisioning Profile
The \*.mobileprovisioning profile can be changed in order to match your signing identity. Mobile Provisioning Profiles can be downloaded directly from iTunes Connect or found in Finder using 'Go > Go to Folder' or <kbd>shift</kbd>+<kbd>command</kbd>+<kbd>G</kbd> using path `~/Library/MobileDevice/Provisioning Profiles`.

### Smallprint
Use this script at your own risk - but it works on my machine!
