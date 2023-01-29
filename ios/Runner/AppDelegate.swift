import UIKit
import Flutter
import flutter_downloader
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
//    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//      messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
      if #available(iOS 10.0, *) {
           UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
          }

       application.registerForRemoteNotifications()
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    WorkmanagerPlugin.registerTask(withIdentifier: "socket-keep-alive")
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
