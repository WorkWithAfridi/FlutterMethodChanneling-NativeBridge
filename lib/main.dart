import 'package:flutter/material.dart';
import 'package:flutter_method_channeling/service/native_bridge.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NativeInfoScreen(),
    );
  }
}

class NativeInfoScreen extends StatefulWidget {
  const NativeInfoScreen({super.key});

  @override
  _NativeInfoScreenState createState() => _NativeInfoScreenState();
}

class _NativeInfoScreenState extends State<NativeInfoScreen> {
  String platformVersion = "Tap to fetch data";
  String batteryLevel = "";
  String deviceModel = "";
  String freeStorage = "";
  String location = "";
  String screenshotPath = "";

  Future<void> fetchPlatformVersion() async {
    String version = await NativeBridge.getPlatformVersion();
    setState(() => platformVersion = version);
  }

  Future<void> fetchBatteryLevel() async {
    String battery = await NativeBridge.getBatteryLevel();
    setState(() => batteryLevel = battery);
  }

  Future<void> fetchDeviceModel() async {
    String model = await NativeBridge.getDeviceModel();
    setState(() => deviceModel = model);
  }

  Future<void> fetchFreeStorage() async {
    String storage = await NativeBridge.getFreeStorage();
    setState(() => freeStorage = storage);
  }

  Future<void> fetchLocation() async {
    String loc = await NativeBridge.getLocation();
    setState(() => location = loc);
  }

  Future<void> showAlert() async {
    await NativeBridge.showAlert("This is a native alert!");
  }

  Future<void> takeScreenshot() async {
    String path = await NativeBridge.takeScreenshot();
    setState(() => screenshotPath = path);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Screenshot saved!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Native Info")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InfoTile(label: "Platform Version", value: platformVersion, onTap: fetchPlatformVersion),
              InfoTile(label: "Battery Level", value: batteryLevel, onTap: fetchBatteryLevel),
              InfoTile(label: "Device Model", value: deviceModel, onTap: fetchDeviceModel),
              InfoTile(label: "Free Storage", value: freeStorage, onTap: fetchFreeStorage),
              InfoTile(label: "Current Location", value: location, onTap: fetchLocation),
              ElevatedButton(
                onPressed: showAlert,
                child: Text("Show Native Alert"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: takeScreenshot,
                child: Text("Take Screenshot"),
              ),
              SizedBox(height: 20),
              if (screenshotPath.isNotEmpty) Text("Screenshot saved at: $screenshotPath", textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const InfoTile({super.key, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: IconButton(icon: Icon(Icons.refresh), onPressed: onTap),
      ),
    );
  }
}
