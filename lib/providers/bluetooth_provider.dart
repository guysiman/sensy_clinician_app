import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider with ChangeNotifier {
  BluetoothDevice? _IPG;
  BluetoothDevice? _EC;
  BluetoothDevice? _sensors;

  BluetoothDevice? get IPG => _IPG;
  BluetoothDevice? get EC => _EC;
  BluetoothDevice? get sensors => _sensors;

  void setIPG(BluetoothDevice device) {
    _IPG = device;
    notifyListeners();
  }

  void clearIPG() {
    _IPG = null;
    notifyListeners();
  }

  void setEC(BluetoothDevice device) {
    _EC = device;
    notifyListeners();
  }

  void clearEC() {
    _EC = null;
    notifyListeners();
  }

  void setSensors(BluetoothDevice device) {
    _sensors = device;
    notifyListeners();
  }

  void clearSensors() {
    _sensors = null;
    notifyListeners();
  }
}
