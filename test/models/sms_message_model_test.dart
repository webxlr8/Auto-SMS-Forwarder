import 'package:flutter_test/flutter_test.dart';
import 'package:sms_forward_app/models/sms_message_model.dart';

void main() {
  group('SmsMessageModel', () {
    test('should create with provided values', () {
      final timestamp = DateTime.now();
      final message = SmsMessageModel(
        sender: '+123456789',
        body: 'Hello, this is a test message',
        timestamp: timestamp,
      );
      
      expect(message.sender, '+123456789');
      expect(message.body, 'Hello, this is a test message');
      expect(message.timestamp, timestamp);
      expect(message.isForwarded, false);
    });
    
    test('should convert to and from JSON', () {
      final timestamp = DateTime(2025, 5, 4, 15, 30);
      final message = SmsMessageModel(
        sender: '+123456789',
        body: 'Hello, this is a test message',
        timestamp: timestamp,
        isForwarded: true,
      );
      
      final json = message.toJson();
      final fromJson = SmsMessageModel.fromJson(json);
      
      expect(fromJson.sender, message.sender);
      expect(fromJson.body, message.body);
      expect(fromJson.timestamp.toIso8601String(), message.timestamp.toIso8601String());
      expect(fromJson.isForwarded, message.isForwarded);
    });
    
    test('should handle empty values from JSON', () {
      final json = {
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final message = SmsMessageModel.fromJson(json);
      
      expect(message.sender, '');
      expect(message.body, '');
      expect(message.isForwarded, false);
    });
  });
}