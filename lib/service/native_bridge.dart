import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.example.app/native');

  // Fetch Platform Version
  static Future<String> getPlatformVersion() async {
    try {
      final String version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    } catch (e) {
      return "Error: $e";
    }
  }

  // Fetch Battery Level
  static Future<String> getBatteryLevel() async {
    try {
      final int batteryLevel = await _channel.invokeMethod('getBatteryLevel');
      return "Battery Level: $batteryLevel%";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Fetch Device Model
  static Future<String> getDeviceModel() async {
    try {
      final String model = await _channel.invokeMethod('getDeviceModel');
      return "Device Model: $model";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Fetch Free Storage Space
  static Future<String> getFreeStorage() async {
    try {
      final String storage = await _channel.invokeMethod('getFreeStorage');
      return "Free Storage: $storage";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Get Current GPS Location
  static Future<String> getLocation() async {
    try {
      final String location = await _channel.invokeMethod('getLocation');
      return "Current Location: $location";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Show a Native Alert Dialog
  static Future<void> showAlert(String message) async {
    try {
      await _channel.invokeMethod('showAlert', {'message': message});
    } catch (e) {
      print("Error: $e");
    }
  }

  // Take Screenshot
  static Future<String> takeScreenshot() async {
    try {
      final String screenshotPath = await _channel.invokeMethod('takeScreenshot');
      return "Screenshot saved at: $screenshotPath";
    } catch (e) {
      return "Error: $e";
    }
  }
}
