import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';

import '../providers/bluetooth_provider.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> devices = [];
  StreamSubscription? scanSubscription;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    super.dispose();
  }


  Future<void> _startScanning() async {
    setState(() {
      devices.clear();
    });

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
    print("-- SCAN STARTED --");

    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (ScanResult r in results) {
          if (r.device.advName.isNotEmpty && !devices.contains(r.device)) {
            devices.add(r.device);
          }
        }
      });
    });
  }

  Future<void> _readLiveData(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
        in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              String receivedData = String.fromCharCodes(value);
              print("📡 Data Received: $receivedData");
            });
            print("-- -- Listening for live data on ${characteristic.uuid}");
          }
        }
      }
    } catch (e) {
      print("XX Error reading live data: $e");
    }
  }

  Future<void> _connectToDevice(
      BluetoothDevice device, String deviceType) async {
    try {
      await device.connect(autoConnect: false);
      print("-- -- Connected to ${device.advName}");

      switch (deviceType.toLowerCase()) {
        case 'ipg':
          context.read<BluetoothProvider>().setIPG(device);
          break;
        case 'external controller':
          context.read<BluetoothProvider>().setEC(device);
          break;
      }

      Navigator.pushNamed(context, '/devicepairingpage');
      _discoverServices(device);
      // 📡 Start reading live data
      _readLiveData(device);
    } catch (e) {
      print("XX Connection failed: $e");
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.read) {
          List<int> value = await characteristic.read();
          print("Data Received: $value");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {


    String deviceType =
        ModalRoute.of(context)?.settings.arguments as String? ?? "default";

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(color: Color(0xFF2D4F63)),
        title: Text('Back',
            style: TextStyle(color: Color(0xFF2D4F63), fontSize: 18)),
        titleSpacing: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _startScanning),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_getTitle(deviceType),
                  style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 24),
              Text('Searching nearby...',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Color(0xFF9CB1B7))),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: devices
                    .map((device) => _buildDeviceButton(device, deviceType))
                    .toList(),
              ),
              SizedBox(height: 118),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('How to connect your device via Bluetooth',
                    style: Theme.of(context).textTheme.labelMedium),
              ),
              SizedBox(height: 12),
              _buildInstructions(deviceType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceButton(BluetoothDevice device, String deviceType) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Color(0xFFEEF3F4), borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        title:
        Text(device.advName, style: Theme.of(context).textTheme.bodyLarge),
        trailing: TextButton(
          onPressed: () => _connectToDevice(device, deviceType),
          child: Text('Connect',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
      ),
    );
  }

  Widget _buildInstructions(String deviceName) {
    List<String> instructions = _getInstructions(deviceName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructions
          .map((instruction) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _buildInstructionStep(instruction),
      ))
          .toList(),
    );
  }

  Widget _buildInstructionStep(String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(top: 8, right: 8),
          decoration:
          BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE3A69C)),
        ),
        Expanded(
            child: Text(description,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.normal))),
      ],
    );
  }

  String _getTitle(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'ipg':
        return 'Pair an IPG';
      case 'external controller':
        return 'Pair an EC';
      default:
        return 'Pair Device';
    }
  }

  List<String> _getInstructions(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'ipg':
        return [
          'Step one — place the charging unit above the implant.',
          'Step two — press the pairing button on a charging unit for 10 seconds.',
          'Step three — press connect button.'
        ];
      case 'external controller':
        return [
          'Step one — Press the pairing button on the External Controller.',
          'Step two — Press connect.'
        ];
      default:
        return ['Step one', 'Step two'];
    }
  }
}
