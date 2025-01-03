// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const BLEApp());
// }

// class BLEApp extends StatelessWidget {
//   const BLEApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BLE Smartwatch Connect',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const BLEHomePage(),
//     );
//   }
// }

// class BLEHomePage extends StatefulWidget {
//   const BLEHomePage({super.key});

//   @override
//   _BLEHomePageState createState() => _BLEHomePageState();
// }

// class _BLEHomePageState extends State<BLEHomePage> {
//   final flutterReactiveBle = FlutterReactiveBle();
//   final List<DiscoveredDevice> scanResults = [];

//   Future<void> requestPermissions() async {
//     await [
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//       Permission.location
//     ].request();
//   }

//   void startScan() async {
//     await requestPermissions();

//     setState(() {
//       scanResults.clear();
//     });

//     flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
//       if (!scanResults.any((d) => d.id == device.id)) {
//         setState(() {
//           scanResults.add(device);
//         });
//       }
//     });
//   }

//   void connectToDevice(DiscoveredDevice device) async {
//     try {
//       await flutterReactiveBle.connectToDevice(id: device.id).first;
//       debugPrint('Connected to ${device.name}');

//       // Check for device properties before interacting
//       checkCharacteristicProperties(device);
//     } catch (e) {
//       debugPrint('Error connecting: $e');
//     }
//   }

//   void checkCharacteristicProperties(DiscoveredDevice device) async {
//     final services = await flutterReactiveBle.discoverServices(device.id);
//     int count = 0;

//     for (var service in services) {
//       for (var characteristic in service.characteristics) {
//         debugPrint('$count Characteristic: ${characteristic.characteristicId}');

//         // Check readability
//         try {
//           await flutterReactiveBle.readCharacteristic(
//             QualifiedCharacteristic(
//               serviceId: service.serviceId,
//               characteristicId: characteristic.characteristicId,
//               deviceId: device.id,
//             ),
//           );
//           debugPrint('Characteristic is Readable');
//         } catch (e) {
//           debugPrint('Characteristic not readable');
//         }

//         // Check if notifiable
//         try {
//           flutterReactiveBle
//               .subscribeToCharacteristic(
//             QualifiedCharacteristic(
//               serviceId: service.serviceId,
//               characteristicId: characteristic.characteristicId,
//               deviceId: device.id,
//             ),
//           )
//               .listen((data) {
//             debugPrint(
//                 'Notification received for ${characteristic.characteristicId}');
//           });
//           debugPrint('Characteristic is Notifiable');
//         } catch (e) {
//           debugPrint('Characteristic not notifiable');
//         }

//         // Check if writable
//         try {
//           await flutterReactiveBle.writeCharacteristicWithResponse(
//             QualifiedCharacteristic(
//               serviceId: service.serviceId,
//               characteristicId: characteristic.characteristicId,
//               deviceId: device.id,
//             ),
//             value: [0x01],
//           );
//           debugPrint('Characteristic is Writable');
//         } catch (e) {
//           debugPrint('Characteristic not writable');
//         }

//         count++;
//       }
//     }
//   }

//   void readCharacteristic(DiscoveredDevice device, Uuid serviceUuid,
//       Uuid characteristicUuid) async {
//     final characteristic = QualifiedCharacteristic(
//       serviceId: serviceUuid,
//       characteristicId: characteristicUuid,
//       deviceId: device.id,
//     );
//     try {
//       final value = await flutterReactiveBle.readCharacteristic(characteristic);
//       debugPrint('Value (String): ${String.fromCharCodes(value)}');
//       debugPrint(
//           'Value (Hex): ${value.map((b) => b.toRadixString(16)).join(' ')}');
//     } catch (e) {
//       debugPrint('Error reading characteristic: $e');
//     }
//   }

//   void subscribeToNotifications(
//       DiscoveredDevice device, Uuid serviceUuid, Uuid characteristicUuid) {
//     final characteristic = QualifiedCharacteristic(
//       serviceId: serviceUuid,
//       characteristicId: characteristicUuid,
//       deviceId: device.id,
//     );

//     flutterReactiveBle.subscribeToCharacteristic(characteristic).listen(
//       (data) {
//         debugPrint(
//             'Notification Data: ${data.map((byte) => byte.toRadixString(16)).join(' ')}');
//       },
//       onError: (error) => debugPrint('Error subscribing: $error'),
//     );
//   }

//   void writeToCharacteristic(DiscoveredDevice device, Uuid serviceUuid,
//       Uuid characteristicUuid, List<int> value) async {
//     final characteristic = QualifiedCharacteristic(
//       serviceId: serviceUuid,
//       characteristicId: characteristicUuid,
//       deviceId: device.id,
//     );

//     try {
//       await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
//           value: value);
//       debugPrint('Write Successful');
//     } catch (e) {
//       debugPrint('Error writing to characteristic: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('BLE Smartwatch Connect')),
//       body: Column(
//         children: [
//           ElevatedButton(
//               onPressed: startScan, child: const Text('Scan Devices')),
//           Expanded(
//             child: scanResults.isEmpty
//                 ? const Center(child: Text('No devices found'))
//                 : ListView.builder(
//                     itemCount: scanResults.length,
//                     itemBuilder: (context, index) {
//                       final result = scanResults[index];
//                       return ListTile(
//                         title: Text(result.name.isNotEmpty
//                             ? result.name
//                             : 'Unnamed Device'),
//                         subtitle: Text(result.id),
//                         trailing: ElevatedButton(
//                           onPressed: () => connectToDevice(result),
//                           child: const Text('Connect'),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
  Map<String, List<Uuid>> deviceServices = {};

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
      deviceServices.clear();
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
      await discoverDeviceServices(device);
    } catch (e) {
      debugPrint('Error connecting: $e');
    }
  }

  Future<void> discoverDeviceServices(DiscoveredDevice device) async {
    final services = await flutterReactiveBle.discoverServices(device.id);
    setState(() {
      deviceServices[device.id] =
          services.map((service) => service.serviceId).toList();
    });
  }

  void checkCharacteristicProperties(DiscoveredDevice device) async {
    final services = await flutterReactiveBle.discoverServices(device.id);
    int count = 0;

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        debugPrint('$count Characteristic: ${characteristic.characteristicId}');

        try {
          await flutterReactiveBle.readCharacteristic(
            QualifiedCharacteristic(
              serviceId: service.serviceId,
              characteristicId: characteristic.characteristicId,
              deviceId: device.id,
            ),
          );
          debugPrint('Characteristic is Readable');
        } catch (e) {
          debugPrint('Characteristic not readable');
        }

        try {
          flutterReactiveBle
              .subscribeToCharacteristic(
            QualifiedCharacteristic(
              serviceId: service.serviceId,
              characteristicId: characteristic.characteristicId,
              deviceId: device.id,
            ),
          )
              .listen((data) {
            debugPrint(
                'Notification received for ${characteristic.characteristicId}');
          });
          debugPrint('Characteristic is Notifiable');
        } catch (e) {
          debugPrint('Characteristic not notifiable');
        }

        try {
          await flutterReactiveBle.writeCharacteristicWithResponse(
            QualifiedCharacteristic(
              serviceId: service.serviceId,
              characteristicId: characteristic.characteristicId,
              deviceId: device.id,
            ),
            value: [0x01],
          );
          debugPrint('Characteristic is Writable');
        } catch (e) {
          debugPrint('Characteristic not writable');
        }

        count++;
      }
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
                      return ExpansionTile(
                        title: Text(result.name.isNotEmpty
                            ? result.name
                            : 'Unnamed Device'),
                        subtitle:
                            Text('ID: ${result.id}\nRSSI: ${result.rssi}'),
                        trailing: ElevatedButton(
                          onPressed: () => connectToDevice(result),
                          child: const Text('Connect'),
                        ),
                        children: [
                          if (deviceServices.containsKey(result.id))
                            ...deviceServices[result.id]!.map(
                              (uuid) => ListTile(
                                title: Text('Service UUID: $uuid'),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
