import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import 'messages_screen.dart';
import 'settings_screen.dart';
import '../services/sms_service.dart';
import '../services/settings_service.dart';
import '../services/message_log_service.dart';

class HomeScreen extends StatefulWidget {
  final bool demoMode;
  
  const HomeScreen({
    Key? key,
    this.demoMode = false,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late SmsService _smsService;
  late SettingsService _settingsService;
  late MessageLogService _messageLogService;
  late SettingsModel _settings;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
    _messageLogService = MessageLogService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _settings = await _settingsService.loadSettings();
      
      _smsService = SmsService(
        settings: _settings,
        onMessageReceived: _handleMessageReceived,
        onError: _handleServiceError,
      );
      
      // Initialize the service
      await _smsService.initialize();
      
      // If in demo mode, show a short notification
      if (widget.demoMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Running in demo mode. SMS functionality is simulated.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading settings: $e';
      });
    }
  }

  void _handleServiceError(String error) {
    // Show errors without crashing the app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleMessageReceived(message) {
    try {
      if (_settings.logMessages) {
        _messageLogService.logMessage(message);
      }
      // Refresh UI if on messages screen
      if (_currentIndex == 0) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error handling received message: $e');
    }
  }

  Future<void> _saveSettings(SettingsModel newSettings) async {
    try {
      setState(() {
        _settings = newSettings;
        _smsService.settings = newSettings;
      });
      await _settingsService.saveSettings(newSettings);
    } catch (e) {
      _handleServiceError('Failed to save settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Auto SMS Forwarder - Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadSettings,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<Widget> screens = [
      MessagesScreen(messageLogService: _messageLogService),
      SettingsScreen(
        initialSettings: _settings,
        onSettingsChanged: _saveSettings,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Auto SMS Forwarder ${widget.demoMode ? "(Demo)" : ""}'),
        actions: [
          if (widget.demoMode)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: const Text('DEMO'),
                backgroundColor: Colors.amber.shade200,
                labelStyle: const TextStyle(fontSize: 12),
              ),
            ),
          Switch(
            value: _settings.isEnabled,
            onChanged: (value) {
              setState(() {
                _settings.isEnabled = value;
                _saveSettings(_settings);
              });
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _smsService.dispose();
    super.dispose();
  }
}