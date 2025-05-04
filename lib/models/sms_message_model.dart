class SmsMessageModel {
  final String sender;
  final String body;
  final DateTime timestamp;
  bool isForwarded;
  bool isDemoMessage;

  SmsMessageModel({
    required this.sender,
    required this.body,
    required this.timestamp,
    this.isForwarded = false,
    this.isDemoMessage = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isForwarded': isForwarded,
      'isDemoMessage': isDemoMessage,
    };
  }

  factory SmsMessageModel.fromJson(Map<String, dynamic> json) {
    return SmsMessageModel(
      sender: json['sender'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isForwarded: json['isForwarded'] as bool? ?? false,
      isDemoMessage: json['isDemoMessage'] as bool? ?? false,
    );
  }
}