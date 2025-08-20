fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios build_enterprise
```
fastlane ios build_enterprise
```
Build enterprise
### ios release_testflight
```
fastlane ios release_testflight
```
Build and upload a PROD app to TestFlight
### ios build_appstore
```
fastlane ios build_appstore
```

### ios upload_testflight
```
fastlane ios upload_testflight
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
