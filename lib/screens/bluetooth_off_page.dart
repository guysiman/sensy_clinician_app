import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:app_settings/app_settings.dart';

class BluetoothOffPage extends StatefulWidget {
  const BluetoothOffPage({super.key});

  @override
  _BluetoothOffPageState createState() => _BluetoothOffPageState();
}

class _BluetoothOffPageState extends State<BluetoothOffPage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();

  @override
  void initState() {
    super.initState();
    _listenToBluetoothState();
  }

  void _listenToBluetoothState() {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        // Navigate to the device pairing page when Bluetooth is turned on
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/devicepairingpage');
        }
      }
    });
  }

  Future<void> _openBluetoothSettings() async {
    AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  }

  String _getTitle(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'ipg':
        return 'Pair an IPG';
      case 'external controller':
        return 'Pair an EC';
      case 'external sensors':
        return 'Pair sensors';
      default:
        return 'Pair Device';
    }
  }

  Widget bluetoothIcon() {
    return Container(
      width: 80, // Adjust size as needed
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFFEBF0F1), // Light background color
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.bluetooth,
          size: 40, // Adjust icon size
          color: Color(0xFF2D4F63), // Match color to your theme
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String deviceType = "default";
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      deviceType = args;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(
          color: Color(0xFF2D4F63),
        ),
        title: Text(
          'Back',
          style: TextStyle(
            color: Color(0xFF2D4F63),
            fontSize: 18,
          ),
        ),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _getTitle(deviceType),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                child: Column(
                  //how to put this column in the center vertically
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      bluetoothIcon(),
                      SizedBox(height: 40),
                      Text(
                        'Bluetooth is off',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enable it to connect the $deviceType',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.normal),
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _openBluetoothSettings,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text('Open settings'),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
