# 🛀 Douchat

### A Flutter chat application avoiding Firebase and using socket-io. 🔌

## ❤️ Shoutout to vykes-mac

He made the base structure and UI of the app. A big thanks to him.

**You can find him on Youtube : https://www.youtube.com/c/islandcoder876**<br>
**You can find him on Github : https://github.com/vykes-mac**

<br>

##  📱 Setting up the app

### I. General

Download and install the Flutter SDK [here](https://docs.flutter.dev/get-started/install).

Copy and paste the ".env.example" into the root project and rename the new file as ".env".
<br>The two variables to add in this file are :
<ul>
<li>DOUCHAT_URI : The url of the Douchat server. It is written with the form : server.example.com</li>
<li>TENOR_API_KEY : The API key of the Tenor API. It is optional, but you can't search or send gifs without it. You can get one on the <a href="https://tenor.com/">Tenor Website</a></li>
</ul>

### II. Android

First, download the latest [Bundletool](https://github.com/google/bundletool/releases).<br>
You can optionally make an alias for bundletool to save time. (alias on linux, Set-Alias on Windows, ...).
<br>
<br>

Secondly, download Java (min version > 8).

<br>
<br>

Thirdly, Install the Android platform-tools to get the adb utility : <a href="https://developer.android.com/studio/releases/platform-tools">platform-tools</a>
<br>
<br>
<br>
Next, allow USB debugging on your Android device and plug it to your machine. <br><br>Get to the root of the project and run : 

```console
flutter pub get
flutter build appbundle
cd build/app/outputs/bundle/release
bundletool build-apks --bundle=./release.aab --output=douchat.apks --mode=universal
bundletool install-apks --apks=./douchat.apks --device-id=DEVICE_ID --adb=path/to/adb
```

The DEVICE_ID is the id of your android device. You can get it by running

```console
adb devices
```

The path/to/adb is the path where adb is installed. It may depend based on the platform you are working on.

<br>

### III. iOS

🚧 This part is not complete.

iOS version > 11.0 required.

I have not tested to build on iOS as I don't have any iPhone.

I have tested the application on an iPhone simulator and it works but there is still some functionalities that do not work or partially work, such as downloading videos or accessing photo library.

### You may try to build the iOS application yourself, but there is no guarentee that it will work.

