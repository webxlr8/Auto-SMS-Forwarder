# Auto SMS Forwarder

[![Flutter Version](https://img.shields.io/badge/Flutter-3.7.2+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Auto SMS Forwarder is a powerful mobile application that automatically forwards incoming SMS messages to designated phone numbers. It's perfect for situations where you need to share incoming messages with another device or person, such as managing dual SIM setups, business communications, or maintaining access to verification codes across multiple devices.

![Auto SMS Forwarder App](https://github.com/webxlr8/Auto-SMS-Forwarder/raw/main/screenshots/app_screenshot.png)

## Features

- **Automatic SMS Forwarding**: Forward incoming SMS messages to one or multiple phone numbers automatically
- **Blocklist Management**: Choose to block specific numbers from being forwarded
- **Intuitive Settings**: Simple, user-friendly interface for easy configuration
- **Message History**: Keep a log of received messages
- **Background Service**: Continues to work even when the app is not in focus
- **Customizable Operation**: Enable or disable forwarding with a single toggle
- **Demo Mode**: Test functionality without requiring actual SMS permissions
- **Multi-Platform Support**: Works on various Android devices (Android 7.0+)

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Setting Up the Development Environment](#setting-up-the-development-environment)
- [Usage Guide](#usage-guide)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Contact & Support](#contact--support)

## Requirements

- Android 7.0 (Nougat) or higher
- SMS Permissions
- For development: Flutter SDK 3.7.2 or higher

## Installation

### Option 1: Download from Releases

1. Visit the [Releases](https://github.com/webxlr8/Auto-SMS-Forwarder/releases) section of the repository
2. Download the latest APK file
3. Enable "Install from Unknown Sources" in your Android device settings
4. Install the downloaded APK

### Option 2: Build from Source

Follow the [Setting Up the Development Environment](#setting-up-the-development-environment) instructions to build the app from source.

## Setting Up the Development Environment

### Prerequisites

1. Install [Flutter](https://flutter.dev/docs/get-started/install) (version 3.7.2 or higher)
2. Install [Git](https://git-scm.com/downloads)
3. Install [Android Studio](https://developer.android.com/studio) with Flutter plugins

### Clone and Build

1. Clone the repository:
   ```bash
   git clone https://github.com/webxlr8/Auto-SMS-Forwarder.git
   ```

2. Navigate to the project directory:
   ```bash
   cd Auto-SMS-Forwarder
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app in debug mode:
   ```bash
   flutter run
   ```

5. Build a release version:
   ```bash
   flutter build apk --release
   ```
   The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## Usage Guide

### Initial Setup

1. **Launch the app** and grant the required SMS permissions when prompted
2. Toggle the main switch at the top of the app to enable SMS forwarding

### Adding Destination Numbers

1. Navigate to the **Settings** tab
2. Under "Where to Send Messages", enter the phone number that should receive forwarded messages
3. Tap the "Add" button
4. You can add multiple destination numbers if needed

### Managing Blocked Senders

1. In the **Settings** tab, scroll to the "Blocked Senders" section
2. To block a sender, enter their phone number and tap the "Block" button
3. To unblock a sender, tap the delete icon next to their number in the list

### Message History

1. The **Messages** tab displays a history of received SMS messages
2. You can see which messages were forwarded successfully
3. Use the clear button to delete the message history

### Demo Mode

If you don't want to grant SMS permissions, you can still test the app's functionality:

1. When prompted for permissions, tap "Continue in Demo Mode"
2. The app will simulate incoming messages to demonstrate the forwarding functionality

## Architecture

Auto SMS Forwarder is built using the Flutter framework and follows a service-based architecture:

- **Models**: Data structures for settings and SMS messages
- **Services**: Core functionality for SMS handling, settings management, and message logging
- **Screens**: User interface components
- **Background Service**: Ensures the app continues to forward messages even when not in focus

Key components:
- `SmsService`: Handles SMS reception and forwarding
- `SettingsModel`: Manages user preferences and forwarding rules
- `MessageLogService`: Maintains the history of received messages

## Contributing

We welcome contributions to the Auto SMS Forwarder project! Here's how you can help:

1. **Fork the Repository**: Create your own copy of the project
2. **Create a Branch**: `git checkout -b feature/your-feature-name`
3. **Make Changes**: Implement your feature or bug fix
4. **Run Tests**: Ensure all tests pass with `flutter test`
5. **Commit Changes**: `git commit -m "Add your descriptive commit message"`
6. **Push to Branch**: `git push origin feature/your-feature-name`
7. **Submit a Pull Request**: Open a PR against the main repository

### Contribution Guidelines

- Follow the existing code style and architecture
- Add appropriate comments and documentation
- Write tests for new functionality
- Update the README if necessary

## Troubleshooting

### Common Issues

#### App Not Receiving SMS

1. Check that SMS permissions are granted in your device settings
2. Ensure the main toggle switch in the app is turned on
3. Verify that the sender is not in the blocked list
4. Restart the app and check for any error notifications

#### Messages Not Being Forwarded

1. Verify that you've added destination numbers correctly
2. Check your device's network connectivity
3. Make sure the app's main toggle switch is enabled
4. Check if the sender is in the blocked list

#### Background Service Issues

1. Ensure battery optimization is disabled for the app in device settings
2. Restart your device and the app
3. Check if any system settings are preventing background services

#### Permission Problems

1. Go to your device settings > Apps > Auto SMS Forwarder > Permissions
2. Ensure SMS permissions are granted
3. For Android 11+, additional permissions may be needed

### Getting Help

If you encounter issues not covered here, please:

1. Check the [Issues](https://github.com/webxlr8/Auto-SMS-Forwarder/issues) section to see if your problem has been reported
2. Create a new issue with detailed information about your problem
3. Include device information, Android version, and steps to reproduce

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact & Support

- **Developer**: [webxlr8](https://github.com/webxlr8)
- **Report Issues**: [Issue Tracker](https://github.com/webxlr8/Auto-SMS-Forwarder/issues)
- **Feature Requests**: Submit feature requests through the Issue Tracker with the "enhancement" label

---

*Auto SMS Forwarder is not affiliated with any cellular carrier and requires standard SMS rates that may apply based on your carrier plan.*
