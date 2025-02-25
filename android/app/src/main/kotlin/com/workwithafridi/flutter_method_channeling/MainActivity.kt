package com.example.app

import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
import android.content.pm.PackageManager


class MainActivity : FlutterActivity() {
    // Define a MethodChannel with a unique identifier
    private val CHANNEL = "com.example.app/native"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel to listen for calls from Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformVersion" -> result.success("Android " + Build.VERSION.RELEASE)
                "getBatteryLevel" -> result.success(getBatteryLevel()) // Call battery level method
                "getDeviceModel" -> result.success(Build.MODEL) // Get device model
                "getFreeStorage" -> result.success(getFreeStorage()) // Get storage info
                "getLocation" -> result.success(getMockLocation()) // Mock GPS location
                "showAlert" -> showAlert(call.argument("message")!!) // Show native alert
                "takeScreenshot" -> result.success(takeScreenshot()) // Capture screenshot
                else -> result.notImplemented()
            }
        }
    }

    // Get the battery level (Mocked; real implementation requires BatteryManager API)
    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as android.os.BatteryManager
        return batteryManager.getIntProperty(android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }
    

    // Get free storage space in MB
    private fun getFreeStorage(): String {
        val stat = filesDir
        val availableBytes = stat.freeSpace / (1024 * 1024)
        return "$availableBytes MB"
    }
    

    // Mock location data (Real implementation requires GPS permissions)
    private fun getMockLocation(): String {
        if (checkSelfPermission(android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return "Location permission not granted"
        }
        return "Latitude: 37.7749, Longitude: -122.4194"
    }
    

    // Show a native Android Toast message
    private fun showAlert(message: String) {
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(this@MainActivity, message, Toast.LENGTH_LONG).show()
        }
    }
    
    // Mock taking a screenshot (Real implementation requires a Screenshot API)
    private fun takeScreenshot(): String {
        val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
        val file = File(cacheDir, "screenshot_$timestamp.png") // Use cache directory
        return file.absolutePath
    }
    
}