import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BLEApp());
}

class BLEApp extends StatelessWidget {
  const BLEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Smartwatch Connect',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BLEHomePage(),
    );
  }
}

class BLEHomePage extends StatefulWidget {
  const BLEHomePage({super.key});

  @override
  _BLEHomePageState createState() => _BLEHomePageState();
}

class _BLEHomePageState extends State<BLEHomePage> {
  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> scanResults = [];

  Future<void> requestPermissions() async {
    await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
  }

  void startScan() async {
    await requestPermissions();

    setState(() {
      scanResults.clear();
    });

    flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      if (!scanResults.any((d) => d.id == device.id)) {
        setState(() {
          scanResults.add(device);
        });
      }
    });
  }

 void connectToDevice(DiscoveredDevice device) async {
  try {
    await flutterReactiveBle.connectToDevice(id: device.id).first;
    debugPrint('Connected to ${device.name}');

    // Discover GATT Services immediately after connecting
    final services = await flutterReactiveBle.discoverServices(device.id);
    debugPrint("Discovered Services: $services");

  } catch (e) {
    debugPrint('Error connecting: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Smartwatch Connect')),
      body: Column(
        children: [
          ElevatedButton(onPressed: startScan, child: const Text('Scan Devices')),
          Expanded(
            child: scanResults.isEmpty
                ? const Center(child: Text('No devices found'))
                : ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      final result = scanResults[index];
                      return ListTile(
                        title: Text(result.name.isNotEmpty ? result.name : 'Unnamed Device'),
                        subtitle: Text(result.id),
                        trailing: ElevatedButton(
                          onPressed: () => connectToDevice(result),
                          child: const Text('Connect'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
