import UIKit
import Flutter
import CoreLocation

/// The AppDelegate class, responsible for setting up the Flutter application 
/// and handling method channel communication with the native iOS side.
@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
    
    /// Instance of CLLocationManager to fetch current location.
    var locationManager = CLLocationManager()

    /// Called when the application has finished launching.
    /// Sets up the Flutter method channel and listens for method calls from Dart.
    ///
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: A dictionary containing information about the reason the app was launched.
    /// - Returns: `true` if the application launched successfully.
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Get the root FlutterViewController.
        let controller = window?.rootViewController as! FlutterViewController
        
        // Create a method channel for communication with Flutter.
        let channel = FlutterMethodChannel(name: "com.example.app/native", binaryMessenger: controller.binaryMessenger)

        // Set a method call handler to respond to calls from Flutter.
        channel.setMethodCallHandler { (call, result) in
            switch call.method {
                case "getPlatformVersion":
                    // Returns the iOS version.
                    result("iOS " + UIDevice.current.systemVersion)
                
                case "getBatteryLevel":
                    // Fetches and returns the battery level.
                    result(Int(UIDevice.current.batteryLevel * 100))
                
                case "getDeviceModel":
                    // Returns the device model.
                    result(UIDevice.current.model)
                
                case "getFreeStorage":
                    // Calls the function to fetch available storage space.
                    result(self.getFreeStorageSpace())
                
                case "getLocation":
                    // Fetches the current GPS location.
                    self.getCurrentLocation { location in result(location) }
                
                case "showAlert":
                    // Displays a native alert dialog with the given message.
                    let message = call.arguments as? String ?? "Default Message"
                    self.showNativeAlert(message: message)
                    result(nil)
                
                case "takeScreenshot":
                    // Takes a screenshot and returns the file path.
                    result(self.takeScreenshot())
                
                default:
                    // If the method is not implemented, return an error.
                    result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// Retrieves the amount of free storage space available on the device.
    ///
    /// - Returns: A string indicating the available storage space in MB.
    private func getFreeStorageSpace() -> String {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let freeSpace = values.volumeAvailableCapacity {
                return "\(freeSpace / (1024 * 1024)) MB free"
            }
        } catch {
            return "Storage info not available"
        }
        
        return "Storage info not available"
    }

    /// Fetches the current GPS location of the device.
    ///
    /// - Parameter completion: A closure returning the location as a string.
    private func getCurrentLocation(completion: @escaping (String) -> Void) {
        // Request permission to access location services.
        locationManager.requestWhenInUseAuthorization()
        
        if let location = locationManager.location {
            // Return the latitude and longitude of the device.
            completion("Lat: \(location.coordinate.latitude), Lng: \(location.coordinate.longitude)")
        } else {
            completion("Location not available")
        }
    }

    /// Displays a native alert dialog with a given message.
    ///
    /// - Parameter message: The message to be displayed in the alert.
    private func showNativeAlert(message: String) {
        let alert = UIAlertController(title: "Native Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Present the alert on the main UI thread.
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alert, animated: true)
        }
    }

    /// Captures a screenshot of the current screen.
    ///
    /// - Returns: A string indicating the file path where the screenshot was saved.
    private func takeScreenshot() -> String {
        // Get the root window.
        guard let window = UIApplication.shared.windows.first else {
            return "Error: No active window found"
        }

        // Render the view into an image.
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Save the image to the device.
        if let image = screenshot, let imageData = image.pngData() {
            let filePath = NSTemporaryDirectory().appending("screenshot.png")
            FileManager.default.createFile(atPath: filePath, contents: imageData, attributes: nil)
            return "Screenshot saved at: \(filePath)"
        }
        
        return "Error capturing screenshot"
    }
}