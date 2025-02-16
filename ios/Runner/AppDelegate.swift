import UIKit
import Flutter
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.example.app/native", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { (call, result) in
            switch call.method {
                case "getPlatformVersion":
                    result("iOS " + UIDevice.current.systemVersion)
                case "getBatteryLevel":
                    result(Int(UIDevice.current.batteryLevel * 100))
                case "getDeviceModel":
                    result(UIDevice.current.model)
                case "getFreeStorage":
                    result(self.getFreeStorageSpace())
                case "getLocation":
                    self.getCurrentLocation { location in result(location) }
                case "showAlert":
                    let message = call.arguments as? String ?? "Default Message"
                    self.showNativeAlert(message: message)
                    result(nil)
                case "takeScreenshot":
                    result(self.takeScreenshot())
                default:
                    result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getFreeStorageSpace() -> String {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        if let values = try? fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey]), let freeSpace = values.volumeAvailableCapacity {
            return "\(freeSpace / (1024 * 1024)) MB free"
        }
        return "Storage info not available"
    }

    private func getCurrentLocation(completion: @escaping (String) -> Void) {
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location {
            completion("Lat: \(location.coordinate.latitude), Lng: \(location.coordinate.longitude)")
        } else {
            completion("Location not available")
        }
    }

    private func showNativeAlert(message: String) {
        let alert = UIAlertController(title: "Native Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        window?.rootViewController?.present(alert, animated: true)
    }

    private func takeScreenshot() -> String {
        return "Screenshot saved!"
    }
}
