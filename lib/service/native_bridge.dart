import 'package:flutter/services.dart';

/// NativeBridge class acts as a bridge between Flutter and the native platform.
/// It uses a MethodChannel to invoke platform-specific methods.
class NativeBridge {
  // Define a MethodChannel with a unique channel name.
  static const MethodChannel _channel = MethodChannel('com.example.app/native');

  /// Fetch the platform version (Android/iOS)
  static Future<String> getPlatformVersion() async {
    try {
      // Call the native method 'getPlatformVersion' and return the result.
      final String version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    } catch (e) {
      return "Error: $e"; // Handle any exceptions
    }
  }

  /// Fetch the battery level of the device
  static Future<String> getBatteryLevel() async {
    try {
      // Call the native method 'getBatteryLevel' and return the result.
      final int batteryLevel = await _channel.invokeMethod('getBatteryLevel');
      return "Battery Level: $batteryLevel%";
    } catch (e) {
      return "Error: $e"; // Handle any errors
    }
  }

  /// Fetch the device model (e.g., "Samsung Galaxy S21" or "iPhone 14")
  static Future<String> getDeviceModel() async {
    try {
      // Call the native method 'getDeviceModel'
      final String model = await _channel.invokeMethod('getDeviceModel');
      return "Device Model: $model";
    } catch (e) {
      return "Error: $e";
    }
  }

  /// Fetch the available free storage space on the device
  static Future<String> getFreeStorage() async {
    try {
      // Call the native method 'getFreeStorage'
      final String storage = await _channel.invokeMethod('getFreeStorage');
      return "Free Storage: $storage";
    } catch (e) {
      return "Error: $e";
    }
  }

  /// Fetch the current GPS location of the device
  static Future<String> getLocation() async {
    try {
      // Call the native method 'getLocation'
      final String location = await _channel.invokeMethod('getLocation');
      return "Current Location: $location";
    } catch (e) {
      return "Error: $e";
    }
  }

  /// Show a native alert dialog (uses native UI components)
  static Future<void> showAlert(String message) async {
    try {
      // Invoke the native method 'showAlert' and pass the message as an argument
      await _channel.invokeMethod('showAlert', {'message': message});
    } catch (e) {
      print("Error: $e");
    }
  }

  /// Take a screenshot and return the file path where it is saved
  static Future<String> takeScreenshot() async {
    try {
      // Call the native method 'takeScreenshot'
      final String screenshotPath = await _channel.invokeMethod('takeScreenshot');
      return "Screenshot saved at: $screenshotPath";
    } catch (e) {
      return "Error: $e";
    }
  }
}
