import 'package:flutter/material.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsModel initialSettings;
  final Function(SettingsModel) onSettingsChanged;

  const SettingsScreen({
    Key? key,
    required this.initialSettings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsModel _settings;
  late TextEditingController _newNumberController;
  late TextEditingController _newSenderController;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _newNumberController = TextEditingController();
    _newSenderController = TextEditingController();
  }

  @override
  void dispose() {
    _newNumberController.dispose();
    _newSenderController.dispose();
    super.dispose();
  }

  void _updateSettings() {
    widget.onSettingsChanged(_settings);
  }

  void _addDestinationNumber() {
    final number = _newNumberController.text.trim();
    if (number.isNotEmpty && !_settings.destinationNumbers.contains(number)) {
      setState(() {
        _settings.destinationNumbers.add(number);
        _newNumberController.clear();
      });
      _updateSettings();
    }
  }

  void _removeDestinationNumber(String number) {
    setState(() {
      _settings.destinationNumbers.remove(number);
    });
    _updateSettings();
  }

  void _addBlockedSender() {
    final sender = _newSenderController.text.trim();
    if (sender.isNotEmpty && !_settings.blockedSenders.contains(sender)) {
      setState(() {
        _settings.blockedSenders.add(sender);
        _newSenderController.clear();
      });
      _updateSettings();
    }
  }

  void _removeBlockedSender(String sender) {
    setState(() {
      _settings.blockedSenders.remove(sender);
    });
    _updateSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // App-wide toggle
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            children: [
              const Icon(
                Icons.swap_horiz,
                size: 28,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto SMS Forwarder',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Enable or disable the entire app',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _settings.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _settings.isEnabled = value;
                  });
                  _updateSettings();
                },
              ),
            ],
          ),
        ),

        // General Settings Section
        _buildSectionHeader(
          context,
          'How Messages Are Handled',
          Icons.settings,
          'Control which messages are forwarded and logged',
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Forward All Messages'),
                  subtitle: const Text(
                    'Send all incoming messages (except from blocked numbers)',
                    style: TextStyle(fontSize: 13),
                  ),
                  secondary: const Icon(Icons.forward_to_inbox, color: Colors.blue),
                  value: _settings.forwardAll,
                  onChanged: (value) {
                    setState(() {
                      _settings.forwardAll = value;
                    });
                    _updateSettings();
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Save Message History'),
                  subtitle: const Text(
                    'Keep a record of received messages in the app',
                    style: TextStyle(fontSize: 13),
                  ),
                  secondary: const Icon(Icons.history, color: Colors.blue),
                  value: _settings.logMessages,
                  onChanged: (value) {
                    setState(() {
                      _settings.logMessages = value;
                    });
                    _updateSettings();
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Destination Numbers Section
        _buildSectionHeader(
          context,
          'Where to Send Messages',
          Icons.phone_android,
          'Add phone numbers that will receive forwarded messages',
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter number with country code',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: _addDestinationNumber,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_settings.destinationNumbers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No numbers added yet. Add a phone number above to receive forwarded messages.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.list, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Numbers receiving messages:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._settings.destinationNumbers
                          .map((number) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: Colors.blue[50],
                                child: ListTile(
                                  leading: const Icon(Icons.phone_forwarded, color: Colors.blue),
                                  title: Text(number),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeDestinationNumber(number),
                                    tooltip: 'Remove this number',
                                  ),
                                ),
                              ))
                          .toList(),
                    ],
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Sender Management Section
        _buildSectionHeader(
          context,
          'Blocked Senders',
          Icons.block,
          'Add phone numbers here to prevent their messages from being forwarded',
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[100]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'By default, SMS from all senders will be forwarded. Add numbers here to block specific senders from being forwarded.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newSenderController,
                        decoration: const InputDecoration(
                          labelText: 'Sender\'s Number',
                          hintText: 'Enter phone number',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.block),
                      label: const Text('Block'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      onPressed: _addBlockedSender,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Blocked Senders List
                if (_settings.blockedSenders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No blocked senders yet',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.list, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Blocked Numbers:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...(_settings.blockedSenders
                          .map((sender) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: Colors.red[50],
                                child: ListTile(
                                  leading: const Icon(Icons.block, color: Colors.red),
                                  title: Text(sender),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeBlockedSender(sender),
                                    tooltip: 'Unblock this sender',
                                  ),
                                ),
                              ))
                          .toList()),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 4.0),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
        ],
      ),
    );
  }
}