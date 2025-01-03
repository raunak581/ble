import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.request();
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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<DiscoveredDevice> scanResults = [];

  int previousHeartRate = -1;
  int notificationCount = 0;
  final int maxNotifications = 3;

  final Uuid nordicUartServiceUuid =
      Uuid.parse('6e400001-b5a3-f393-e0a9-e50e24dcca9e');
  final Uuid txCharacteristicUuid =
      Uuid.parse('6e400003-b5a3-f393-e0a9-e50e24dcca9e');
  final Uuid rxCharacteristicUuid =
      Uuid.parse('6e400002-b5a3-f393-e0a9-e50e24dcca9e');

  Future<void> requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();
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
      subscribeToHeartRateNotifications(device);
    } catch (e) {
      debugPrint('Error connecting: $e');
    }
  }

  void subscribeToHeartRateNotifications(DiscoveredDevice device) {
    final heartRateCharacteristic = QualifiedCharacteristic(
      serviceId: nordicUartServiceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: device.id,
    );

    flutterReactiveBle
        .subscribeToCharacteristic(heartRateCharacteristic)
        .listen(
      (data) {
        if (data.isNotEmpty) {
          final heartRate = data[1];
          debugPrint('❤️ Heart Rate: $heartRate bpm');
          sendNotificationToMobile('Heart rate dropped: $heartRate bpm');

          if (previousHeartRate != -1 && heartRate < previousHeartRate) {
            notificationCount++;
            sendNotificationToMobile('Heart rate dropped: $heartRate bpm');
            debugPrint(
                '⚠️ Heart rate dropped! Notification Sent: $notificationCount');
          }

          if (heartRate >= previousHeartRate) {
            notificationCount = 0;
          }
          previousHeartRate = heartRate;
        }
      },
      onError: (error) => debugPrint('Error receiving heart rate: $error'),
    );
  }

  void sendNotificationToMobile(String message) async {
    if (notificationCount <= maxNotifications) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'heart_rate_channel',
        'Heart Rate Monitor',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Heart Rate Alert!',
        message,
        notificationDetails,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Smartwatch Connect')),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: startScan, child: const Text('Scan Devices')),
          Expanded(
            child: scanResults.isEmpty
                ? const Center(child: Text('No devices found'))
                : ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      final result = scanResults[index];
                      return ListTile(
                        title: Text(result.name.isNotEmpty
                            ? result.name
                            : 'Unnamed Device'),
                        subtitle: Text(result.id),
                        trailing: ElevatedButton(
                          onPressed: () => connectToDevice(result),
                          child: const Text('Connect & Monitor Heart Rate'),
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
