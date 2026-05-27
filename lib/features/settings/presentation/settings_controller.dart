import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  late SharedPreferences _prefs;

  final RxString currentTheme = 'System'.obs;
  final RxBool isNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // Loads settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load notifications enabled state (defaults to true)
      isNotificationsEnabled.value = _prefs.getBool('notifications_enabled') ?? true;

      // Load theme preferences (defaults to System)
      final String savedTheme = _prefs.getString('theme_preference') ?? 'System';
      currentTheme.value = savedTheme;
      _applyTheme(savedTheme);
    } catch (_) {
      // Graceful fallback for failures in early initialized environments
    }
  }

  // Modifies theme mode and writes back to local cache
  Future<void> changeTheme(String themeName) async {
    currentTheme.value = themeName;
    _applyTheme(themeName);
    try {
      await _prefs.setString('theme_preference', themeName);
    } catch (_) {}
  }

  // Internal theme mode dispatcher helper
  void _applyTheme(String themeName) {
    switch (themeName) {
      case 'Light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'Dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'System':
      default:
        Get.changeThemeMode(ThemeMode.system);
        break;
    }
  }

  // Toggles notifications state and writes back to local cache
  Future<void> toggleNotifications(bool value) async {
    isNotificationsEnabled.value = value;
    try {
      await _prefs.setBool('notifications_enabled', value);
    } catch (_) {}
  }
}
