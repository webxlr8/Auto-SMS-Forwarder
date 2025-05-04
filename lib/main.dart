import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';

// Global error handler to prevent app crashes
void _handleError(Object error, StackTrace stack) {
  debugPrint('ERROR CAUGHT BY ZONE: $error');
  debugPrint(stack.toString());
  // You could add error reporting to a service like Firebase Crashlytics here
}

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Catch any errors that happen during app initialization
  runZonedGuarded(() async {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  
    // Error handling for Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('FLUTTER ERROR: ${details.exception}');
      debugPrint(details.stack.toString());
    };
    
    runApp(const SMSForwardApp());
  }, _handleError);
}

class SMSForwardApp extends StatefulWidget {
  const SMSForwardApp({Key? key}) : super(key: key);

  @override
  _SMSForwardAppState createState() => _SMSForwardAppState();
}

class _SMSForwardAppState extends State<SMSForwardApp> {
  bool _permissionsGranted = false;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final status = await Permission.sms.status;
      
      setState(() {
        _permissionsGranted = status.isGranted;
        _errorMessage = '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking permissions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final status = await Permission.sms.request();
      
      setState(() {
        _permissionsGranted = status.isGranted;
        _isLoading = false;
      });
      
      // Show reason if permission denied
      if (!status.isGranted) {
        setState(() {
          _errorMessage = status.isPermanentlyDenied 
              ? 'Permission permanently denied. Please enable SMS permissions in app settings.' 
              : 'Permission denied. SMS functionality will not work without this permission.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error requesting permissions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openAppSettings() async {
    try {
      if (await openAppSettings()) {
        // App settings opened
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable SMS permissions in app settings'),
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Could not open app settings';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error opening app settings: $e';
      });
    }
  }

  void _enterDemoMode(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(demoMode: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto SMS Forwarder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: _permissionsGranted
          ? const HomeScreen(demoMode: false)
          : Scaffold(
              appBar: AppBar(
                title: const Text('Auto SMS Forwarder'),
                backgroundColor: Colors.blue.shade100,
              ),
              body: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sms_failed, size: 72, color: Colors.orange),
                        const SizedBox(height: 24),
                        const Text(
                          'SMS permissions are required',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'This app needs permission to read SMS messages in order to forward them.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade800),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(color: Colors.red.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _requestPermissions,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Grant SMS Permissions'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                        FutureBuilder<bool>(
                          future: Permission.sms.isPermanentlyDenied,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data == true) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: ElevatedButton.icon(
                                  onPressed: _openAppSettings,
                                  icon: const Icon(Icons.settings),
                                  label: const Text('Open App Settings'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text(
                          "Don't want to grant permissions?",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => _enterDemoMode(context),
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('Continue in Demo Mode'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Demo mode uses simulated messages only',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ),
    );
  }
}
