import 'package:flutter/material.dart';
import '../models/sms_message_model.dart';
import '../services/message_log_service.dart';

class MessagesScreen extends StatefulWidget {
  final MessageLogService messageLogService;
  
  const MessagesScreen({
    Key? key,
    required this.messageLogService,
  }) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<SmsMessageModel> _messages = [];
  bool _isLoading = true;
  bool _showDemoMessages = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final messages = await widget.messageLogService.getMessageLog();
      
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load messages: $e';
      });
    }
  }

  Future<void> _clearLog() async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear Message Log'),
          content: const Text('Are you sure you want to clear all message logs?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Show loading indicator
                setState(() => _isLoading = true);
                
                await widget.messageLogService.clearLog();
                _loadMessages();
              },
              child: const Text('CLEAR'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing log: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<SmsMessageModel> get _filteredMessages {
    if (_showDemoMessages) {
      return _messages;
    } else {
      return _messages.where((msg) => !msg.isDemoMessage).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMessages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sms_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No messages received yet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMessages,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Check if we have any real messages
    bool hasRealMessages = _messages.any((msg) => !msg.isDemoMessage);
    bool hasOnlyDemoMessages = !hasRealMessages && _messages.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: Column(
        children: [
          if (hasOnlyDemoMessages)
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.amber.shade100,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Mode Active',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'These are simulated messages for testing purposes. No real SMS data is being used.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Demo message toggle
                if (_messages.any((msg) => msg.isDemoMessage))
                  Expanded(
                    child: Row(
                      children: [
                        Switch(
                          value: _showDemoMessages,
                          onChanged: (value) {
                            setState(() {
                              _showDemoMessages = value;
                            });
                          },
                        ),
                        const Text(
                          'Show Demo Messages',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _clearLog,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Clear Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredMessages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_alt, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No messages match your filter settings',
                            textAlign: TextAlign.center,
                          ),
                          if (!_showDemoMessages)
                            TextButton(
                              onPressed: () => setState(() => _showDemoMessages = true),
                              child: const Text('Show All Messages'),
                            ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = _filteredMessages[index];
                      return MessageListItem(message: message);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class MessageListItem extends StatelessWidget {
  final SmsMessageModel message;

  const MessageListItem({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color cardColor = message.isDemoMessage 
        ? Colors.grey.shade50 
        : message.isForwarded 
            ? Colors.green.withOpacity(0.05)
            : Colors.white;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: message.isDemoMessage 
              ? Colors.amber.withOpacity(0.5) 
              : message.isForwarded 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: message.isDemoMessage 
              ? Colors.amber.withOpacity(0.2) 
              : Colors.blue.withOpacity(0.2),
          child: Icon(
            message.isDemoMessage ? Icons.auto_fix_high : Icons.sms,
            color: message.isDemoMessage ? Colors.amber.shade800 : Colors.blue,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message.sender,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (message.isDemoMessage)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message.body,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (message.isForwarded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Forwarded',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hours:$minutes';
  }
}