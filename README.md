#Fyber Corona Test App
---

####Using the test app

**Required**: You must have Corona Enterprise to build this plugin and test app.

#####Android
Open the `android` directory in Android Studio, then run the `app` configuration.

Notes:

* You may need to disable Instant Run, it seemed to be causing issues for us.
* If you start to get `SIGSEV` crashes with `GLThread` in the error when trying to run a new version of the APK during development, delete the `build/` directories (one in the top-level folder, one in `app/`, and one in `/plugin`.

#####iOS
Open `ios/FyberCoronaTest.xcodeproj` in Xcode.

---


####Steps to test with your own credentials
#####All platforms
* Replace the App ID and Security Token in `Corona/main.lua` in the call to initialize the SDK 
  * ex: `fyberLib.CallMethod("init", "app_id_here", "security_token_here")`

#####Android
* Replace `"com.fyber.example.fybercorona"` with your own package name in `android/app/src/main/AndroidManifest.xml`

* Change the value of `app_name` in `android/app/src/main/res/values/strings.xml` to match your application's name
* Optionally add any additional networks to the `android/plugin/build.gradle` 
  * You can find instructions for this in the Fyber Android integration docs - there may be other steps, like adding `AndroidManifest` entries

#####iOS
* Replace the Bundle Identifer in Xcode under the General settings tab of the test app target.
* Optionally add any additional networks to the project by dragging in the `.embeddedframework` folders into Xcode (download these from Fyber's iOS integration docs)

