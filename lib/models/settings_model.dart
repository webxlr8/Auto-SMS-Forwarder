enum ForwardingMethod {
  sms,
}

class SettingsModel {
  bool isEnabled;
  List<String> allowedSenders;
  List<String> blockedSenders;
  List<String> destinationNumbers;
  bool forwardAll;
  bool logMessages;

  SettingsModel({
    this.isEnabled = false,
    List<String>? allowedSenders,
    List<String>? blockedSenders,
    List<String>? destinationNumbers,
    this.forwardAll = true, // Now defaults to true
    this.logMessages = true,
  }) : 
    // Initialize with modifiable copies of the lists
    allowedSenders = allowedSenders != null ? List<String>.from(allowedSenders) : [],
    blockedSenders = blockedSenders != null ? List<String>.from(blockedSenders) : [],
    destinationNumbers = destinationNumbers != null ? List<String>.from(destinationNumbers) : [];

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'allowedSenders': allowedSenders,
      'blockedSenders': blockedSenders,
      'destinationNumbers': destinationNumbers,
      'forwardAll': forwardAll,
      'logMessages': logMessages,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isEnabled: json['isEnabled'] ?? false,
      allowedSenders: List<String>.from(json['allowedSenders'] ?? []),
      blockedSenders: List<String>.from(json['blockedSenders'] ?? []),
      destinationNumbers: List<String>.from(json['destinationNumbers'] ?? []),
      forwardAll: json['forwardAll'] ?? true, // Default is now true
      logMessages: json['logMessages'] ?? true,
    );
  }

  bool shouldForwardMessage(String sender) {
    // Don't forward if forwarding is disabled at app level
    if (!isEnabled) return false;
    
    // Don't forward if sender is in the blocked list
    if (blockedSenders.contains(sender)) {
      return false;
    }
    
    // Forward all other messages
    return true;
  }
}