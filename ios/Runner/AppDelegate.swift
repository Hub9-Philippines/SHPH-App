import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Provide the Google Maps API Key safely before any UI rendering occurs
    GMSServices.provideAPIKey("AIzaSyCyNmGRVmX5--jXElXLS6HVXriyPTGGnoY") 
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Mandatory override to enable proper window attachment via UIScene lifecycle
  @available(iOS 13.0, *)
  override func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    // Routes window attachment through Flutter's modern engine delegate layers
    return FlutterSceneConfiguration(
      session: connectingSceneSession, 
      connectingOptions: options
    )
  }
}
