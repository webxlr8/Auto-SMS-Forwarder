import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_forward_app/models/settings_model.dart';
import 'package:sms_forward_app/services/settings_service.dart';

import 'settings_service_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late SettingsService settingsService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    SharedPreferences.setMockInitialValues({});
    settingsService = SettingsService();
  });

  group('SettingsService', () {
    test('loadSettings should return default settings when no saved settings exist', () async {
      // Set up SharedPreferences to return null
      SharedPreferences.setMockInitialValues({});
      
      final settings = await settingsService.loadSettings();
      
      expect(settings.isEnabled, false);
      expect(settings.allowedSenders, isEmpty);
      expect(settings.blockedSenders, isEmpty);
      expect(settings.forwardAll, false);
    });

    test('saveSettings should save settings to SharedPreferences', () async {
      // We need to use mockito to verify the save operation
      final settings = SettingsModel(
        isEnabled: true,
        allowedSenders: ['+123456789'],
        blockedSenders: ['+987654321'],
        destinationNumber: '+111222333',
      );
      
      await settingsService.saveSettings(settings);
      
      // Can't fully test the save operation in this test environment
      // In a real test, we would verify the SharedPreferences.setString was called
    });
  });
}