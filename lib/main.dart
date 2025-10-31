import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/voice_assistant_screen.dart';
import 'core/theme/app_theme.dart';

/// ElevenLabs Voice Chat
///
/// A Flutter application that provides real-time voice conversations with
/// ElevenLabs AI agents. Features include:
/// - Real-time voice recording and streaming
/// - Live speech-to-text transcription
/// - Natural voice responses from AI agents
/// - Clean, minimal user interface
/// - Native Android integration via ElevenLabs SDK
///
/// The app uses the ElevenLabs Conversational AI platform for voice
/// interactions and requires proper configuration in the .env file.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables containing ElevenLabs credentials
  await dotenv.load(fileName: ".env");

  // Request microphone permission for voice recording
  // This is required for the voice conversation functionality
  await Permission.microphone.request();

  runApp(const VoiceAssistantApp());
}

/// Root application widget that configures the app theme and navigation
///
/// Sets up the MaterialApp with a dark theme optimized for voice interactions
/// and initializes the main voice assistant screen.
class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElevenLabs Voice Chat',
      theme: AppTheme.darkTheme,
      home: const VoiceAssistantScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
