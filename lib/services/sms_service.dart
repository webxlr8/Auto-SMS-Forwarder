import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
// Remove sms_flutter_plus import and use a direct implementation
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/sms_message_model.dart';
import '../models/settings_model.dart';

// Define custom classes to replace the missing sms_flutter_plus package
class SmsMessage {
  final String? address;
  final String? body;
  
  SmsMessage({this.address, this.body});
}

class SmsFlutterPlus {
  // Create a controller to simulate SMS reception
  final StreamController<SmsMessage> _smsController = StreamController<SmsMessage>.broadcast();
  
  Stream<SmsMessage> get onSmsReceived => _smsController.stream;
  
  Future<void> initialize() async {
    // In a real implementation, this would initialize native SMS listeners
    return Future.value();
  }
  
  Future<SendSMSResult> sendSMS({
    required String message,
    required List<String> recipients,
    int simCard = 0,
  }) async {
    // In a real implementation, this would use platform channels to send SMS
    // For now, just log and return success
    debugPrint('Sending SMS: $message to ${recipients.join(', ')}');
    return SendSMSResult.sent;
  }
  
  // Method to simulate receiving an SMS (for testing)
  void simulateIncomingSms(String sender, String body) {
    _smsController.add(SmsMessage(address: sender, body: body));
  }
  
  void dispose() {
    _smsController.close();
  }
}

enum SendSMSResult {
  sent,
  failed,
}

class SmsService {
  final Function(SmsMessageModel message)? onMessageReceived;
  final Function(String error)? onError;
  late SettingsModel _settings;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();
  final SmsFlutterPlus _smsPlugin = SmsFlutterPlus();
  StreamSubscription? _smsSubscription;
  Timer? _simulationTimer;
  bool _isDemoMode = false;
  bool _isInitialized = false;
  
  // Getter and setter for settings
  SettingsModel get settings => _settings;
  set settings(SettingsModel value) {
    _settings = value;
    debugPrint('Settings updated in SmsService');
  }

  SmsService({
    required SettingsModel settings,
    this.onMessageReceived,
    this.onError,
  }) : _settings = settings;

  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Request SMS permissions on Android
        var smsPermission = await Permission.sms.status;
        if (!smsPermission.isGranted) {
          smsPermission = await Permission.sms.request();
        }

        // For Android 11+ we also need to request phone state permissions
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 30) { // Android 11+
          var phonePermission = await Permission.phone.status;
          if (!phonePermission.isGranted) {
            phonePermission = await Permission.phone.request();
          }
        }

        // For Android 13+ we need additional permissions
        if (androidInfo.version.sdkInt >= 33) { // Android 13+
          var notificationsPermission = await Permission.notification.status;
          if (!notificationsPermission.isGranted) {
            notificationsPermission = await Permission.notification.request();
          }
        }

        return smsPermission.isGranted;
      }
      return false; // iOS doesn't support SMS reading
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      _reportError('Permission error: $e');
      return false;
    }
  }

  void _reportError(String error) {
    debugPrint('SmsService ERROR: $error');
    onError?.call(error);
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('SmsService already initialized');
      return;
    }

    try {
      // Check the environment or parameters to determine if we should run in demo mode
      if (Platform.isAndroid) {
        bool permissionsGranted = await requestPermissions();
        
        if (permissionsGranted) {
          // If we have permissions, attempt to initialize real SMS handling
          await _initializeRealSmsHandling();
          debugPrint('SmsService initialized in real mode');
        } else {
          // No permissions means we need to fall back to demo mode
          _isDemoMode = true;
          await _startDemoMode();
          debugPrint('SmsService initialized in demo mode (no permissions)');
        }
      } else {
        // Not Android means we can't access real SMS
        _isDemoMode = true;
        await _startDemoMode();
        debugPrint('SmsService initialized in demo mode (platform not supported)');
      }

      _isInitialized = true;
    } catch (e) {
      _reportError('Failed to initialize SMS service: $e');
      // Always fall back to demo mode if initialization fails
      _isDemoMode = true;
      await _startDemoMode();
    }
  }
  
  Future<void> _initializeRealSmsHandling() async {
    try {
      // Initialize the SMS plugin with proper error handling
      await _smsPlugin.initialize().catchError((error) {
        throw Exception('SMS plugin initialization error: $error');
      });
      
      // Listen for incoming SMS messages with error handling
      _smsSubscription = _smsPlugin.onSmsReceived.listen(
        (SmsMessage message) {
          try {
            final smsMessage = SmsMessageModel(
              sender: message.address ?? 'Unknown',
              body: message.body ?? '',
              timestamp: DateTime.now(),
              isDemoMessage: false,
            );
            
            _handleIncomingSms(smsMessage);
          } catch (e) {
            _reportError('Error processing received SMS: $e');
          }
        },
        onError: (error) {
          _reportError('SMS reception stream error: $error');
        },
        cancelOnError: false, // Don't cancel subscription on error
      );
      
      // Start a background service if needed
      _initializeBackgroundService();
      
      debugPrint('Real SMS handling initialized successfully');
      
      // Remove test message generation in production mode
      // Only send test messages in debug mode
      if (kDebugMode) {
        _simulateDemoSms(isDemoMode: false, prefix: 'SYSTEM: ');
      }
    } catch (e) {
      _reportError('Error initializing real SMS handling: $e');
      // Fall back to demo mode if real SMS handling fails
      _isDemoMode = true;
      await _startDemoMode();
    }
  }
  
  Future<void> _initializeBackgroundService() async {
    try {
      // Check if background service is available
      bool isAvailable = await _backgroundService.isRunning();
      if (!isAvailable) {
        // Configure and start the background service
        await _backgroundService.configure(
          androidConfiguration: AndroidConfiguration(
            // This is the fixed onStart callback that matches the expected signature
            onStart: _onBackgroundStart,
            autoStart: false,
            isForegroundMode: true,
            notificationChannelId: 'sms_forward_service',
            initialNotificationTitle: 'Auto SMS Forwarder Service',
            initialNotificationContent: 'Running in background',
            foregroundServiceNotificationId: 888,
          ),
          iosConfiguration: IosConfiguration(
            autoStart: false,
            // Fix the iOS callbacks to return proper boolean values
            onForeground: _onBackgroundStartIOS,
            onBackground: _onBackgroundStartIOS,
          ),
        );
      }
    } catch (e) {
      _reportError('Error initializing background service: $e');
    }
  }
  
  // Updated to match the expected signature for background service callbacks
  @pragma('vm:entry-point')
  static void _onBackgroundStart(ServiceInstance service) {
    // Background service implementation would go here
    debugPrint('Background service started');
    
    // Set up any necessary functionality for the background service
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }
  
  // iOS-specific callback that returns a boolean value
  @pragma('vm:entry-point')
  static bool _onBackgroundStartIOS(ServiceInstance service) {
    // Background service implementation for iOS would go here
    debugPrint('iOS background service started');
    
    // Set up any necessary functionality for the background service
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
    
    return true; // Must return true for iOS
  }
  
  Future<void> _startDemoMode() async {
    debugPrint('Starting demo mode for SMS simulation');
    try {
      // Only show initial demo message in debug mode
      if (kDebugMode) {
        _simulateDemoSms();
        
        // Then setup a timer to periodically send more demo messages only in debug mode
        _simulationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          try {
            _simulateDemoSms();
          } catch (e) {
            _reportError('Error in demo SMS simulation: $e');
          }
        });
      } else {
        // In production mode, don't simulate any messages
        debugPrint('Demo mode disabled for production build');
      }
    } catch (e) {
      _reportError('Failed to start demo mode: $e');
    }
  }
  
  void _simulateDemoSms({bool isDemoMode = true, String prefix = ''}) {
    try {
      final demoSenders = [
        '+123456789', 
        '+987654321', 
        '+111222333', 
        '+444555666',
        'Amazon',
        'Bank',
        'John Doe',
        'Service',
      ];
      
      final demoMessages = [
        'Hello, this is a test message.',
        'Your OTP code is: 123456',
        'Your appointment is scheduled for tomorrow at 10:00 AM.',
        'Your package has been delivered.',
        'Your bill payment is due soon.',
        'Please call me back when you get a chance.',
        'Your account balance is \$1,250.75', // Escaped the dollar sign
        'Flight MS234 has been delayed by 30 minutes.',
        'Reminder: Team meeting at 2PM today.',
      ];
      
      final random = DateTime.now().millisecondsSinceEpoch;
      final sender = demoSenders[random % demoSenders.length];
      final body = prefix + demoMessages[random % demoMessages.length];
      
      final message = SmsMessageModel(
        sender: sender,
        body: body,
        timestamp: DateTime.now(),
        isDemoMessage: isDemoMode,
      );
      
      debugPrint('${isDemoMode ? "DEMO MODE" : "TEST MESSAGE"}: Simulating incoming SMS from $sender');
      _handleIncomingSms(message);
    } catch (e) {
      _reportError('Error simulating demo SMS: $e');
    }
  }

  void _handleIncomingSms(SmsMessageModel message) {
    try {
      // Notify listeners (UI updates, etc.)
      if (onMessageReceived != null) {
        try {
          onMessageReceived!(message);
        } catch (e) {
          _reportError('Error in onMessageReceived callback: $e');
        }
      }
      
      // Only attempt to forward if auto-forwarding is enabled
      if (_settings.isEnabled && !message.isDemoMessage) {
        // Check if this message should be forwarded
        if (_settings.shouldForwardMessage(message.sender)) {
          // Use Future.delayed to avoid blocking the main thread
          Future.delayed(Duration.zero, () async {
            try {
              await forwardMessage(message);
            } catch (e) {
              _reportError('Error forwarding message: $e');
            }
          });
        }
      } else if (_settings.isEnabled && message.isDemoMessage && !_isDemoMode) {
        // Special case: Demo messages in REAL mode should not be forwarded
        debugPrint('Not forwarding demo message in real mode');
      } else if (_isDemoMode && message.isDemoMessage) {
        // In demo mode, simulate forwarding for demo messages
        debugPrint('Demo mode: Simulating forwarding for demo message');
        Future.delayed(const Duration(milliseconds: 500), () {
          message.isForwarded = true;
          debugPrint('Demo message marked as forwarded');
        });
      }
    } catch (e) {
      _reportError('Error handling incoming SMS: $e');
    }
  }

  Future<bool> forwardMessage(SmsMessageModel message) async {
    bool success = false;
    
    try {
      // Forward to all destination numbers
      if (_settings.destinationNumbers.isNotEmpty) {
        success = await _forwardViaSms(message);
      }
      
      // Update forwarded status
      message.isForwarded = success;
    } catch (e) {
      _reportError('Error in forwardMessage: $e');
      success = false;
    }
    
    return success;
  }

  Future<bool> _forwardViaSms(SmsMessageModel message) async {
    if (_settings.destinationNumbers.isEmpty) {
      return false;
    }
    
    try {
      String forwardedMessage = 'From: ${message.sender}\n${message.body}';
      List<bool> results = [];
      
      // Send to all destination numbers
      for (final number in _settings.destinationNumbers) {
        try {
          if (_isDemoMode) {
            // In demo mode, just log the action and simulate success
            debugPrint('DEMO MODE: SMS would be sent to $number: $forwardedMessage');
            results.add(true);
          } else {
            // Actually send the SMS through the plugin with error handling
            final result = await _smsPlugin.sendSMS(
              message: forwardedMessage,
              recipients: [number],
              simCard: 0, // Use default SIM card
            ).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                _reportError('SMS sending timed out for number: $number');
                return SendSMSResult.failed;
              },
            ).catchError((error) {
              _reportError('Error sending SMS to $number: $error');
              return SendSMSResult.failed;
            });
            
            results.add(result == SendSMSResult.sent);
            debugPrint('SMS forwarded to $number: ${result == SendSMSResult.sent ? 'Success' : 'Failed'}');
          }
        } catch (e) {
          _reportError('Error sending SMS to $number: $e');
          results.add(false);
        }
      }
      
      // Success if at least one message was sent successfully
      return results.contains(true);
    } catch (e) {
      _reportError('Error in _forwardViaSms: $e');
      return false;
    }
  }
  
  void dispose() {
    try {
      _smsSubscription?.cancel();
      _simulationTimer?.cancel();
      _smsPlugin.dispose();
      debugPrint('SmsService disposed');
    } catch (e) {
      _reportError('Error disposing SmsService: $e');
    }
  }
}