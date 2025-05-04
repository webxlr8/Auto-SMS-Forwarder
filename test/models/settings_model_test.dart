import 'package:flutter_test/flutter_test.dart';
import 'package:sms_forward_app/models/settings_model.dart';

void main() {
  group('SettingsModel', () {
    test('should create with default values', () {
      final settings = SettingsModel();
      
      expect(settings.isEnabled, false);
      expect(settings.allowedSenders, isEmpty);
      expect(settings.blockedSenders, isEmpty);
      expect(settings.destinationNumber, isEmpty);
      expect(settings.webhookUrl, isEmpty);
      expect(settings.forwardingMethod, ForwardingMethod.sms);
      expect(settings.forwardAll, false);
      expect(settings.webhookHeaders, isEmpty);
      expect(settings.logMessages, true);
    });
    
    test('should convert to and from JSON', () {
      final settings = SettingsModel(
        isEnabled: true,
        allowedSenders: ['+123456789'],
        blockedSenders: ['+987654321'],
        destinationNumber: '+111222333',
        webhookUrl: 'https://example.com/webhook',
        forwardingMethod: ForwardingMethod.webhook,
        forwardAll: true,
        webhookHeaders: {'Authorization': 'Bearer token'},
        logMessages: false,
      );
      
      final json = settings.toJson();
      final fromJson = SettingsModel.fromJson(json);
      
      expect(fromJson.isEnabled, settings.isEnabled);
      expect(fromJson.allowedSenders, settings.allowedSenders);
      expect(fromJson.blockedSenders, settings.blockedSenders);
      expect(fromJson.destinationNumber, settings.destinationNumber);
      expect(fromJson.webhookUrl, settings.webhookUrl);
      expect(fromJson.forwardingMethod, settings.forwardingMethod);
      expect(fromJson.forwardAll, settings.forwardAll);
      expect(fromJson.webhookHeaders, settings.webhookHeaders);
      expect(fromJson.logMessages, settings.logMessages);
    });
    
    group('shouldForwardMessage', () {
      test('should not forward if forwarding is disabled', () {
        final settings = SettingsModel(
          isEnabled: false,
          allowedSenders: ['+123456789'],
          forwardAll: true,
        );
        
        expect(settings.shouldForwardMessage('+123456789'), false);
      });
      
      test('should forward allowed sender', () {
        final settings = SettingsModel(
          isEnabled: true,
          allowedSenders: ['+123456789'],
          forwardAll: false,
        );
        
        expect(settings.shouldForwardMessage('+123456789'), true);
        expect(settings.shouldForwardMessage('+987654321'), false);
      });
      
      test('should forward all except blocked senders', () {
        final settings = SettingsModel(
          isEnabled: true,
          blockedSenders: ['+123456789'],
          forwardAll: true,
        );
        
        expect(settings.shouldForwardMessage('+123456789'), false);
        expect(settings.shouldForwardMessage('+987654321'), true);
      });
    });
  });
}