import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sms_message_model.dart';

class MessageLogService {
  static const String _logKey = 'sms_message_log';
  static const int _maxLogSize = 100; // Maximum number of messages to store
  
  Future<List<SmsMessageModel>> getMessageLog() async {
    final prefs = await SharedPreferences.getInstance();
    final logJson = prefs.getStringList(_logKey) ?? [];
    
    return logJson.map((messageJson) {
      final Map<String, dynamic> messageMap = json.decode(messageJson);
      return SmsMessageModel.fromJson(messageMap);
    }).toList();
  }
  
  Future<bool> logMessage(SmsMessageModel message) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logJson = prefs.getStringList(_logKey) ?? [];
    
    // Add the new message
    logJson.insert(0, json.encode(message.toJson()));
    
    // Trim the log if it exceeds the maximum size
    if (logJson.length > _maxLogSize) {
      logJson = logJson.sublist(0, _maxLogSize);
    }
    
    return await prefs.setStringList(_logKey, logJson);
  }
  
  Future<bool> clearLog() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_logKey);
  }
}