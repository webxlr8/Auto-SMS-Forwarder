import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  static const String _settingsKey = 'sms_forward_settings';
  
  Future<SettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson == null) {
      // Return default settings
      return SettingsModel();
    }
    
    try {
      final Map<String, dynamic> settingsMap = json.decode(settingsJson);
      return SettingsModel.fromJson(settingsMap);
    } catch (e) {
      print('Error loading settings: $e');
      return SettingsModel();
    }
  }
  
  Future<bool> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final settingsJson = json.encode(settings.toJson());
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }
}