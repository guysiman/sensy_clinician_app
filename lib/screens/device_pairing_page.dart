import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/bluetooth_provider.dart';

class DevicePairingPage extends StatefulWidget {
  const DevicePairingPage({super.key});

  @override
  _DevicePairingPageState createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends State<DevicePairingPage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  bool isBluetoothOn = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  Future<void> _checkBluetoothState() async {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        isBluetoothOn = true;
      } else {
        isBluetoothOn = false;
      }
    });
  }

  void _checkAndNavigate() {
    final bluetoothProvider =
    Provider.of<BluetoothProvider>(context, listen: false);
    if (bluetoothProvider.IPG != null && bluetoothProvider.EC != null) {
      Navigator.pushReplacementNamed(context, '/mainpage');
    }
  }

  void _navigateScreen(String deviceName) {
    if (isBluetoothOn) {
      Navigator.pushNamed(context, '/bluetoothpage', arguments: deviceName);
    } else {
      Navigator.pushNamed(context, '/bluetoothoffpage', arguments: deviceName);
    }
  }

  Widget buildWriteSection(BluetoothDevice device) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: "Enter Message",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _writeLiveData(device),
          child: Text("Send Data"),
        ),
      ],
    );
  }

  Future<void> _writeLiveData(BluetoothDevice device) async {
    String data = _textController.text;
    if (data.isEmpty) {
      print("⚠️ No message entered. Aborting.");
      return;
    }

    try {
      print("🚀 Attempting to write data to ${device.advName}");
      List<BluetoothService> services = await device.discoverServices();
      print("🔍 Discovered ${services.length} services.");

      for (BluetoothService service in services) {
        print("🔍 Service: ${service.uuid}");
        for (BluetoothCharacteristic characteristic
        in service.characteristics) {
          print(
              "🔎 Characteristic: ${characteristic.uuid} - Properties: ${characteristic.properties}");
          print("🔎 Checking characteristic: ${characteristic.uuid}");

          if (characteristic.properties.write &&
              characteristic.uuid != Guid('2b29')) {
            List<int> bytes = data.codeUnits;
            print("✍ Writing data: $data (Bytes: $bytes)");

            DateTime sendTime = DateTime.now();
            await characteristic.write(bytes, withoutResponse: true);
            print("📤 Data Sent at $sendTime");

            // Check if there's a characteristic for receiving data
            for (BluetoothCharacteristic c in service.characteristics) {
              if (c.properties.notify || c.properties.indicate) {
                await c.setNotifyValue(true);
                c.lastValueStream.listen((value) {
                  String receivedData = String.fromCharCodes(value);
                  print("📡 Received Data: $receivedData");
                });
                print("✅ Listening for response on ${c.uuid}");
                return;
              }
            }

            print("⚠️ No notification characteristic found.");
            return;
          }
        }
      }
      print("⚠️ No writable characteristic found.");
    } catch (e) {
      print("❌ Error writing data: $e");
    }
  }

  Widget device(String deviceName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(deviceName, style: Theme.of(context).textTheme.bodyLarge),
          OutlinedButton(
            onPressed: () {
              _navigateScreen(deviceName);
            },
            child: const Text('Pair'),
          ),
        ],
      ),
    );
  }

  Widget connectedDevice(String deviceName, BluetoothDevice device) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  SizedBox(width: 12),
                  Text(deviceName,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              OutlinedButton(
                onPressed: () => _navigateScreen(deviceName),
                child: const Text('Pair another one'),
              ),
            ],
          ),
          SizedBox(height: 12),
          deviceInfo(deviceName, device),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: "Enter data to send",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _writeLiveData(device),
                  child: Text("Send to $deviceName"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget deviceInfo(String deviceName, BluetoothDevice device) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFFEEF3F4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: "$deviceName name: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: device.platformName),
                ],
              ),
            ),
            Divider(),
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: "$deviceName info: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: device.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BluetoothDevice? IPG = context.watch<BluetoothProvider>().IPG;
    BluetoothDevice? EC = context.watch<BluetoothProvider>().EC;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text('Pairing',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      IPG != null ? connectedDevice('IPG', IPG) : device('IPG'),
                      EC != null
                          ? connectedDevice('EC', EC)
                          : device('External controller')
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/homepage');
                    },
                    child: const Text('Go to the Home Screen'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
