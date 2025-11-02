# 🎤 ElevenLabs Voice Chat

A production-ready Flutter application that provides seamless real-time voice conversations with ElevenLabs AI agents. Built with native Android SDK integration for optimal performance and reliability.

## ✨ Features

- 🎤 **Real-time Voice Conversations** - Natural, low-latency voice interactions with AI agents
- 📝 **Live Transcription** - Real-time speech-to-text display with message history
- 🔊 **High-Quality Audio** - Crystal clear voice responses with professional audio processing
- 📱 **Native Performance** - Optimized using ElevenLabs Android SDK for best-in-class performance
- 🎨 **Modern UI** - Clean, minimal interface with smooth animations and visual feedback
- 🔄 **Connection Management** - Robust WebSocket connection handling with automatic reconnection
- 🎛️ **Conversation Controls** - Mute/unmute, start/stop calls with intuitive controls
- 📊 **Real-time Status** - Live connection status and conversation mode indicators
- 🔒 **Secure Configuration** - Environment-based credential management

## 🏗️ Architecture

### Hybrid Native Integration
The application uses a sophisticated hybrid architecture that combines Flutter's cross-platform UI capabilities with native Android performance for audio processing:

```
┌─────────────────────────────┐    Method Channel    ┌──────────────────────────────┐
│        Flutter Layer        │ ←─────────────────→ │      Native Android Layer    │
│                             │                     │                              │
│ • VoiceAssistantScreen      │                     │ • ElevenLabs Android SDK     │
│ • ElevenLabsNativeService   │                     │ • WebSocket Management       │
│ • TranscriptWidget          │                     │ • Real-time Audio Recording  │
│ • AnimatedAvatar            │                     │ • Audio Stream Processing    │
│ • CallButton Controls       │                     │ • Voice Activity Detection   │
│ • State Management          │                     │ • Kotlin Coroutines         │
└─────────────────────────────┘                     └──────────────────────────────┘
```

### 🔧 Core Components

#### Flutter Layer
- **ElevenLabsNativeService**: Main service orchestrating voice conversations via method channels
- **VoiceAssistantScreen**: Primary UI screen with conversation controls and status display
- **TranscriptWidget**: Real-time conversation transcript with auto-scrolling and message formatting
- **AnimatedAvatar**: Visual feedback component with pulsing animations based on conversation state
- **CallButton**: Interactive call control with smooth animations and loading states

#### Native Android Layer
- **MainActivity**: Kotlin-based native integration with ElevenLabs Android SDK
- **ConversationClient**: Direct SDK integration for WebSocket management and audio processing
- **Method Channel Handler**: Bidirectional communication bridge between Flutter and native code

### 📡 Communication Flow

1. **Initialization**: Flutter requests conversation start via method channel
2. **Native Setup**: Android creates ElevenLabs session with WebSocket connection
3. **Audio Streaming**: Real-time audio capture and streaming to ElevenLabs servers
4. **Event Handling**: Native layer forwards transcription and response events to Flutter
5. **UI Updates**: Flutter updates transcript and visual indicators based on conversation state

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK**: 3.8.1 or higher ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Android Studio**: Latest version with Android SDK 21+ 
- **ElevenLabs Account**: Active account with Conversational AI access
- **Physical Android Device**: Required for audio recording (emulator limitations)

### 📦 Installation

1. **Clone and Navigate**
   ```bash
   git clone <repository-url>
   cd elevenlabs_voice_chat
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure ElevenLabs Credentials**
   
   Create a `.env` file in the project root:
   ```env
   # Required: Your ElevenLabs Agent ID from the dashboard
   ELEVENLABS_AGENT_ID=your_agent_id_here
   
   # Required: Your ElevenLabs API key
   ELEVENLABS_API_KEY=your_api_key_here
   ```

4. **Build and Run**
   ```bash
   # Clean build (recommended for first run)
   flutter clean && flutter pub get
   
   # Run on connected Android device
   flutter run --release
   ```

### 🔐 Android Permissions

The following permissions are automatically configured in `AndroidManifest.xml`:

| Permission | Purpose | Auto-granted |
|------------|---------|--------------|
| `INTERNET` | WebSocket connections to ElevenLabs | Yes |
| `RECORD_AUDIO` | Voice recording and streaming | Runtime request |
| `MODIFY_AUDIO_SETTINGS` | Audio session management | Yes |

> **Note**: Microphone permission is requested at app startup. Grant permission for full functionality.

## 📱 Usage Guide

### Starting Your First Conversation

1. **🚀 Launch the App**
   - Open the app on your Android device
   - Grant microphone permission when prompted
   - You'll see the main interface with an animated avatar

2. **📞 Initiate Connection**
   - Tap the blue call button at the bottom
   - Status changes to "Connecting..." while establishing WebSocket connection
   - Avatar begins glowing when connection is established

3. **🎤 Begin Speaking**
   - Once status shows "Connected", start speaking naturally
   - Your speech is transcribed in real-time and appears in the transcript
   - The avatar pulses when actively listening

4. **🔊 Receive Responses**
   - Agent responses are played through device speakers
   - Response text appears in the transcript with timestamps
   - Conversation flows naturally with minimal latency

### 🎛️ Conversation Controls

| Control | Action | Visual Feedback |
|---------|--------|-----------------|
| **Call Button** | Start/End conversation | Blue (start) → Red (active) |
| **Mute Button** | Toggle microphone | Appears during active calls |
| **Auto-scroll** | View latest messages | Transcript scrolls automatically |

### 📊 Status Indicators

| Status | Meaning | Avatar State |
|--------|---------|--------------|
| **Idle** | No active conversation | Static blue circle |
| **Connecting** | Establishing connection | Gentle glow animation |
| **Connected** | Ready for conversation | Steady glow |
| **Listening** | Processing your speech | Pulsing animation |
| **Processing** | Agent generating response | Steady glow |
| **Error** | Connection issue | Static with error message |

### 💡 Best Practices

- **Speak Clearly**: Natural pace with clear pronunciation works best
- **Wait for Responses**: Allow agent to complete responses before speaking
- **Use Physical Device**: Emulators may have audio limitations
- **Stable Internet**: Ensure strong WiFi or cellular connection for best quality

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `ELEVENLABS_AGENT_ID` | Your ElevenLabs agent identifier | ✅ Yes | `ag_2EXAMPLEa1b2c3d4e5f6` |
| `ELEVENLABS_API_KEY` | Your ElevenLabs API key | ✅ Yes | `sk_1234567890abcdef...` |

### 🤖 ElevenLabs Agent Setup

#### Step 1: Create ElevenLabs Account
1. Visit [ElevenLabs](https://bit.ly/3X5ZzqO) and create an account
2. Navigate to the **Conversational AI** section in the dashboard
3. Ensure you have access to the Conversational AI features

#### Step 2: Create Your Agent
1. Click **"Create Agent"** in the Conversational AI dashboard
2. Configure your agent with:
   - **Name**: Choose a descriptive name
   - **Voice**: Select from available voice models
   - **Personality**: Define agent behavior and responses
   - **Knowledge Base**: Add relevant information for your use case

#### Step 3: Get Credentials
1. **Agent ID**: Copy from your agent's settings page
2. **API Key**: Generate from Account → API Keys section
3. **Add to `.env`**: Place both values in your project's `.env` file

#### Step 4: Test Your Agent
1. Use the ElevenLabs dashboard to test your agent
2. Ensure it responds appropriately to voice input
3. Verify audio quality and response times

### 🔧 Advanced Configuration

#### Audio Settings
The app uses default audio settings optimized for voice conversations:
- **Sample Rate**: 16kHz (optimal for speech)
- **Channels**: Mono (reduces bandwidth)
- **Format**: PCM 16-bit (high quality)

#### Connection Settings
- **WebSocket**: Automatic reconnection enabled
- **Timeout**: 30 seconds for initial connection
- **Keep-alive**: Ping/pong every 30 seconds

## 🛠️ Development

### 📁 Project Structure

```
elevenlabs_voice_chat/
├── lib/
│   ├── main.dart                           # 🚀 App entry point & initialization
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart         # 📏 App-wide constants & dimensions
│   │   └── theme/
│   │       └── app_theme.dart             # 🎨 UI theme & color configuration
│   ├── screens/
│   │   └── voice_assistant_screen.dart    # 📱 Main voice interface screen
│   ├── services/
│   │   └── elevenlabs_native_service.dart # 🔌 ElevenLabs SDK integration service
│   └── widgets/
│       ├── animated_avatar.dart           # 👤 Animated conversation avatar
│       ├── call_button.dart              # 📞 Interactive call control button
│       └── transcript_widget.dart        # 💬 Real-time conversation display
├── android/
│   └── app/src/main/kotlin/
│       └── MainActivity.kt                # 🤖 Native Android SDK integration
├── .env                                   # 🔐 Environment configuration
└── pubspec.yaml                          # 📦 Flutter dependencies
```

### 🔄 Method Channel Communication

The app uses Flutter's method channels for seamless communication between Dart and Kotlin:

#### Flutter → Native (Outbound)
| Method | Parameters | Purpose |
|--------|------------|---------|
| `startConversation` | `agentId`, `userId` | Initiates WebSocket connection and audio streaming |
| `stopConversation` | None | Ends conversation and cleans up resources |
| `sendMessage` | `message` | Sends text message during active conversation |

#### Native → Flutter (Inbound)
| Callback | Data | Purpose |
|----------|------|---------|
| `onConnect` | `conversationId` | Notifies successful connection establishment |
| `onMessage` | `source`, `message` | Forwards transcripts and agent responses |
| `onModeChange` | `mode` | Updates conversation state (listening/speaking) |
| `onStatusChange` | `status` | Reports connection status changes |

### 🔧 Adding New Features

#### 1. Extend Flutter Service
```dart
// In ElevenLabsNativeService
Future<void> newFeature(String parameter) async {
  final result = await _channel.invokeMethod('newMethod', {
    'parameter': parameter,
  });
  // Handle result
}
```

#### 2. Implement Native Handler
```kotlin
// In MainActivity.kt
"newMethod" -> {
    val parameter = call.argument<String>("parameter")
    // Implement native functionality
    result.success("Success")
}
```

#### 3. Update UI Components
```dart
// Add new UI elements that use the service
Widget buildNewFeature() {
  return ElevatedButton(
    onPressed: () => _voiceService.newFeature("value"),
    child: Text("New Feature"),
  );
}
```

### 🧪 Testing Strategy

#### Unit Tests
- Service method validation
- Message parsing logic
- State management verification

#### Integration Tests
- Method channel communication
- Native SDK integration
- End-to-end conversation flow

#### Device Testing
- Audio recording quality
- WebSocket stability
- Performance under various network conditions

### 📊 Performance Optimization

#### Audio Processing
- Use native Android audio APIs for minimal latency
- Implement proper audio session management
- Optimize buffer sizes for real-time streaming

#### Memory Management
- Dispose of resources properly in Flutter widgets
- Clean up native resources in MainActivity
- Monitor memory usage during long conversations

#### Network Optimization
- Implement connection pooling for WebSocket
- Add retry logic with exponential backoff
- Compress audio streams when possible

## 🔧 Troubleshooting

### 🚨 Common Issues & Solutions

#### Connection Problems

**❌ "Connection Failed" Error**
```bash
# Check credentials
cat .env  # Verify ELEVENLABS_AGENT_ID and ELEVENLABS_API_KEY

# Test network connectivity
ping api.elevenlabs.io

# Verify agent exists in ElevenLabs dashboard
```
**✅ Solutions:**
- Verify Agent ID and API key are correct and active
- Check internet connection stability
- Ensure ElevenLabs service is operational ([Status Page](https://status.elevenlabs.io))
- Try restarting the app to refresh credentials

#### Audio Issues

**❌ "No Audio Recording" / Silent Input**
```bash
# Check device audio
adb shell dumpsys audio  # For connected Android device
```
**✅ Solutions:**
- Grant microphone permissions in device settings
- Test on physical device (emulator audio limitations)
- Check device audio settings and volume levels
- Ensure no other apps are using the microphone
- Restart device if audio system is unresponsive

#### Transcript Problems

**❌ "Transcript Not Updating" / Missing Messages**
```bash
# Check logs for parsing errors
flutter logs | grep "Message"
```
**✅ Solutions:**
- Verify WebSocket connection is active (check status indicator)
- Look for JSON parsing errors in console logs
- Ensure agent is configured for transcription in ElevenLabs dashboard
- Check network stability during conversation

#### Build & Development Issues

**❌ Build Errors / Dependency Conflicts**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub deps
flutter run --verbose
```
**✅ Solutions:**
- Update Android SDK and build tools to latest versions
- Verify Kotlin version compatibility (1.8.0+)
- Check Flutter SDK version (3.8.1+)
- Clear Android Studio cache and restart

### 📊 Debug Logging

#### Enable Verbose Logging
```bash
# Run with detailed logs
flutter run --verbose

# Filter specific components
flutter logs | grep "ElevenLabs"
flutter logs | grep "🚀\|📝\|🎤\|❌"
```

#### Log Message Prefixes
| Prefix | Component | Example |
|--------|-----------|---------|
| `🚀` | Connection events | `🚀 Start conversation result: success` |
| `📝` | Message processing | `📝 Adding to transcript: Hello world` |
| `🎤` | Audio events | `🎤 Mute toggled: false` |
| `❌` | Errors | `❌ Error starting call: Invalid agent ID` |
| `🔍` | Message parsing | `🔍 Processing message from ai` |
| `📡` | Status changes | `📡 Status changed: connected` |

### 🩺 Health Checks

#### Verify Installation
```bash
# Check Flutter setup
flutter doctor -v

# Verify dependencies
flutter pub deps

# Test on device
flutter devices
```

#### Test ElevenLabs Integration
```bash
# Test API connectivity (replace with your key)
curl -H "xi-api-key: YOUR_API_KEY" https://api.elevenlabs.io/v1/user

# Verify agent exists
curl -H "xi-api-key: YOUR_API_KEY" https://api.elevenlabs.io/v1/convai/agents
```

### 🆘 Getting Help

#### Before Reporting Issues
1. **Check logs** for specific error messages
2. **Test on physical device** (not emulator)
3. **Verify credentials** are correct and active
4. **Update dependencies** to latest versions
5. **Try minimal reproduction** steps

#### Useful Information to Include
- Device model and Android version
- Flutter SDK version (`flutter --version`)
- Error logs with timestamps
- Steps to reproduce the issue
- ElevenLabs agent configuration details

#### Support Channels
- **App Issues**: Create issue in this repository with logs
- **ElevenLabs API**: [ElevenLabs Documentation](https://elevenlabs.io/docs)
- **Flutter Issues**: [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)
- **Android SDK**: [ElevenLabs Android SDK Docs](https://elevenlabs.io/docs/agents-platform/libraries/kotlin)

## 📦 Dependencies

### Flutter Packages
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_dotenv` | `^5.1.0` | Secure environment variable management |
| `permission_handler` | `^11.3.1` | Runtime permission handling for microphone access |

### Native Dependencies
| Dependency | Platform | Purpose |
|------------|----------|---------|
| `elevenlabs-android` | Android | Official ElevenLabs Android SDK for voice conversations |
| `kotlinx-coroutines-android` | Android | Kotlin coroutines for asynchronous operations |

### Development Dependencies
| Package | Purpose |
|---------|---------|
| `flutter_test` | Unit and widget testing framework |
| `flutter_lints` | Dart code analysis and linting rules |

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Development Setup
1. **Fork** the repository on GitHub
2. **Clone** your fork locally
3. **Create** a feature branch: `git checkout -b feature/amazing-feature`
4. **Install** dependencies: `flutter pub get`
5. **Make** your changes with proper documentation
6. **Test** thoroughly on physical devices
7. **Commit** with descriptive messages
8. **Push** to your fork: `git push origin feature/amazing-feature`
9. **Submit** a pull request with detailed description

### Code Standards
- **Documentation**: All public methods must have comprehensive dartdoc comments
- **Testing**: Add unit tests for new functionality
- **Formatting**: Use `dart format` for consistent code style
- **Linting**: Ensure `flutter analyze` passes without warnings
- **Performance**: Test on various Android devices and network conditions

### Pull Request Guidelines
- **Clear Title**: Describe the change concisely
- **Detailed Description**: Explain what, why, and how
- **Screenshots**: Include UI changes with before/after images
- **Testing**: Describe testing performed
- **Breaking Changes**: Clearly document any breaking changes

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### MIT License Summary
- ✅ **Commercial use** - Use in commercial projects
- ✅ **Modification** - Modify and distribute
- ✅ **Distribution** - Share with others
- ✅ **Private use** - Use privately
- ❗ **Liability** - No warranty provided
- ❗ **Attribution** - Include original license

## 🆘 Support & Community

### Getting Help
| Issue Type | Contact Method | Response Time |
|------------|----------------|---------------|
| **Bug Reports** | [GitHub Issues](https://github.com/your-repo/issues) | 1-3 business days |
| **Feature Requests** | [GitHub Discussions](https://github.com/your-repo/discussions) | 1 week |
| **ElevenLabs API** | [ElevenLabs Support](https://elevenlabs.io/docs) | Per their SLA |
| **Flutter Issues** | [Flutter Community](https://flutter.dev/community) | Community-driven |

### Documentation Links
- 📚 **ElevenLabs Docs**: [elevenlabs.io/docs](https://elevenlabs.io/docs)
- 🤖 **Android SDK**: [ElevenLabs Kotlin SDK](https://elevenlabs.io/docs/agents-platform/libraries/kotlin)
- 🐦 **Flutter Docs**: [docs.flutter.dev](https://docs.flutter.dev)
- 📱 **Method Channels**: [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)

### Community
- 💬 **Discord**: Join our development community
- 🐦 **Twitter**: Follow [@YourProject](https://twitter.com/yourproject) for updates
- 📧 **Newsletter**: Subscribe for release announcements

---

<div align="center">

**Built with ❤️ using Flutter and ElevenLabs**

*Empowering developers to create amazing voice experiences*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![ElevenLabs](https://img.shields.io/badge/ElevenLabs-000000?style=for-the-badge&logo=elevenlabs&logoColor=white)](https://elevenlabs.io)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)

</div>