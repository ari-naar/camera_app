import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticsService {
  static final HapticsService _instance = HapticsService._internal();
  factory HapticsService() => _instance;
  HapticsService._internal();

  bool _isEnabled = true;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('isHapticsEnabled') ?? true;
  }

  bool get isEnabled => _isEnabled;

  Future<void> setEnabled(bool value) async {
    _isEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHapticsEnabled', value);
  }

  void lightImpact() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
  }

  void mediumImpact() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavyImpact() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void selectionClick() {
    if (!_isEnabled) return;
    HapticFeedback.selectionClick();
  }
}
