package com.example.app

import android.app.AlertDialog
import android.content.Context
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.location.Location
import android.location.LocationManager
import android.os.StatFs
import android.view.PixelCopy
import android.view.View
import android.graphics.Bitmap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream
import java.text.SimpleDateFormat
import java.util.*
import android.os.Handler
import android.os.Looper
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat



class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
                "getBatteryLevel" -> {
                    val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
                    val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                    result.success(batteryLevel)
                }
                "getDeviceModel" -> result.success(Build.MODEL)
                "getFreeStorage" -> result.success(getFreeStorageSpace())
                "getLocation" -> result.success(getCurrentLocation())
                "showAlert" -> {
                    val message = call.argument<String>("message") ?: "Default Message"
                    showNativeAlert(message)
                    result.success(null)
                }
        "takeScreenshot" -> takeScreenshot(result)

                else -> result.notImplemented()
            }
        }
    }

    private fun getFreeStorageSpace(): String {
        val stat = StatFs(getExternalFilesDir(null)?.absolutePath ?: return "Storage path not found")
        val freeBytes = stat.availableBytes
        return "${freeBytes / (1024 * 1024)} MB free"
    }    

private fun getCurrentLocation(): String {
    val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager

    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
        ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
        return "Location permission not granted"
    }

    val location: Location? = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
    return location?.let { "Lat: ${it.latitude}, Lng: ${it.longitude}" } ?: "Location not available"
}


    private fun showNativeAlert(message: String) {
        AlertDialog.Builder(this)
            .setTitle("Native Alert")
            .setMessage(message)
            .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
            .show()
    }

    
    private fun takeScreenshot(result: MethodChannel.Result) {
        val view: View = window.decorView.rootView
        val bitmap = Bitmap.createBitmap(view.width, view.height, Bitmap.Config.ARGB_8888)
    
        val handler = Handler(Looper.getMainLooper())
    
        PixelCopy.request(window, bitmap, { copyResult ->
            if (copyResult == PixelCopy.SUCCESS) {
                try {
                    val fileName = "screenshot_${System.currentTimeMillis()}.png"
                    val file = File(getExternalFilesDir(Environment.DIRECTORY_PICTURES), fileName)
                    val outStream: OutputStream = FileOutputStream(file)
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, outStream)
                    outStream.close()
                    
                    // Return the file path
                    result.success(file.absolutePath)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.error("ERROR", "Failed to save screenshot", null)
                }
            } else {
                result.error("ERROR", "PixelCopy failed", null)
            }
        }, handler)
    }
    
}
