import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BatteryService extends ChangeNotifier {
  final Battery _battery = Battery();
  late StreamSubscription<BatteryState> _batteryStateSubscription;
  int _batteryLevel = 0;
  bool _isCharging = false;
  final int _threshold = 97;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasNotified = false;

  BatteryService() {
    _init();
  }

  void _init() async {
    // Initial check
    _isCharging = await _battery.batteryState.then((state) => state == BatteryState.charging);
    _checkBatteryLevel();

    // Listen for changes
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      _isCharging = state == BatteryState.charging;
      if (!_isCharging) {
        _hasNotified = false; // Reset notification flag when unplugged
      }
      _checkBatteryLevel();
    });
  }

  Future<void> _checkBatteryLevel() async {
    final int batteryLevel = await _battery.batteryLevel;
    if (batteryLevel != _batteryLevel) {
      _batteryLevel = batteryLevel;
      if (_isCharging && _batteryLevel >= _threshold && !_hasNotified) {
        _notifyUser();
        _hasNotified = true;
      }
      notifyListeners();
    }
  }

  void _notifyUser() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Fluttertoast.showToast(
        msg: "Battery level reached $_threshold%",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    });
    _playAudio();
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(AssetSource('audio/p_p.mp3'));
  }

  @override
  void dispose() {
    _batteryStateSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}