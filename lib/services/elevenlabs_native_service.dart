import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/app_constants.dart';

/// Represents a single message in the conversation transcript
/// 
/// Contains the message text, sender information, and timestamp
/// for display in the conversation history UI.
class TranscriptMessage {
  /// The actual text content of the message
  final String text;
  
  /// Whether this message was sent by the user (true) or agent (false)
  final bool isUser;
  
  /// When this message was created
  final DateTime timestamp;
  
  /// Creates a new transcript message
  TranscriptMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// ElevenLabs voice conversation service using native Android SDK
/// 
/// This service provides a Flutter interface to the ElevenLabs Android SDK
/// for real-time voice conversations with AI agents. It handles:
/// - WebSocket connection management via native code
/// - Real-time audio recording and streaming
/// - Live transcription of user speech
/// - Agent voice response playback
/// - Conversation state management
/// 
/// The service communicates with native Android code through method channels
/// and maintains the same interface as the original Vapi service for UI compatibility.
class ElevenLabsNativeService extends ChangeNotifier {
  /// Method channel for communicating with native Android code
  static const MethodChannel _channel = MethodChannel('elevenlabs_native');
  
  // Private state variables
  bool _isCallActive = false;
  bool _isLoading = false;
  bool _isMuted = false;
  String _callStatus = 'idle';
  final List<TranscriptMessage> _transcript = [];
  String? _conversationId;
  
  // Public getters for UI state
  
  /// Whether a voice conversation is currently active
  bool get isCallActive => _isCallActive;
  
  /// Whether the service is in a loading state (connecting/disconnecting)
  bool get isLoading => _isLoading;
  
  /// Whether the microphone is currently muted
  bool get isMuted => _isMuted;
  
  /// Current status of the conversation ('idle', 'connecting', 'active', 'listening', 'processing', 'error')
  String get callStatus => _callStatus;
  
  /// Immutable list of conversation transcript messages
  List<TranscriptMessage> get transcript => List.unmodifiable(_transcript);
  
  /// Unique identifier for the current conversation (null if no active conversation)
  String? get conversationId => _conversationId;
  
  /// ElevenLabs agent ID from environment variables
  String get _agentId => dotenv.env[AppConstants.elevenLabsAgentIdEnv] ?? '';

  /// Creates a new ElevenLabs service instance and sets up native communication
  ElevenLabsNativeService() {
    _setupMethodCallHandler();
  }

  /// Sets up the method call handler to receive callbacks from native Android code
  /// 
  /// This handles events from the ElevenLabs Android SDK including:
  /// - Connection status changes
  /// - Incoming messages (transcripts, agent responses)
  /// - Mode changes (listening/speaking)
  /// - General status updates
  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onConnect':
          // Called when successfully connected to ElevenLabs agent
          _conversationId = call.arguments as String?;
          _isCallActive = true;
          _setLoading(false);
          _setCallStatus('active');
          debugPrint('✅ Connected to conversation: $_conversationId');
          break;
          
        case 'onMessage':
          // Called when receiving messages from the agent (transcripts, responses, etc.)
          final data = call.arguments as Map<dynamic, dynamic>;
          final source = data['source'] as String;
          final message = data['message'] as String;
          _handleMessage(source, message);
          break;
          
        case 'onModeChange':
          // Called when conversation mode changes (listening/speaking)
          final mode = call.arguments as String;
          _handleModeChange(mode);
          break;
          
        case 'onStatusChange':
          // Called when connection status changes
          final status = call.arguments as String;
          _handleStatusChange(status);
          break;
      }
    });
  }

  /// Validates that required configuration is available
  /// 
  /// Throws an exception if the ElevenLabs Agent ID is not found
  /// in the environment variables.
  Future<void> initialize() async {
    if (_agentId.isEmpty) {
      throw Exception('ElevenLabs Agent ID not found in environment variables. '
          'Please check your .env file contains ELEVENLABS_AGENT_ID.');
    }
  }

  /// Starts a new voice conversation with the ElevenLabs agent
  /// 
  /// This method:
  /// 1. Validates configuration
  /// 2. Calls native Android code to establish WebSocket connection
  /// 3. Starts audio recording and streaming
  /// 4. Updates UI state to show connection progress
  /// 
  /// Includes retry logic to handle initialization timing issues.
  /// Throws an exception if the conversation cannot be started after retries.
  Future<void> startCall() async {
    if (_isCallActive) return;
    
    _setLoading(true);
    
    try {
      await initialize();
      
      // Add a small delay to ensure native SDK is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Retry logic for initialization issues
      Exception? lastException;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          debugPrint('🔄 Starting conversation attempt $attempt/3');
          
          // Call native Android method to start conversation
          final result = await _channel.invokeMethod('startConversation', {
            'agentId': _agentId,
            'userId': 'flutter_user_${DateTime.now().millisecondsSinceEpoch}',
          });
          
          debugPrint('🚀 Start conversation result: $result');
          _setCallStatus('connecting');
          return; // Success, exit retry loop
          
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          debugPrint('❌ Attempt $attempt failed: $e');
          
          if (attempt < 3) {
            // Wait before retrying, with exponential backoff
            await Future.delayed(Duration(milliseconds: 500 * attempt));
          }
        }
      }
      
      // All attempts failed
      throw lastException ?? Exception('Failed to start conversation after 3 attempts');
      
    } catch (e) {
      _setLoading(false);
      _setCallStatus('error');
      debugPrint('❌ Error starting call: $e');
      rethrow;
    }
  }

  /// Ends the current voice conversation
  /// 
  /// This method:
  /// 1. Calls native Android code to close WebSocket connection
  /// 2. Stops audio recording and playback
  /// 3. Resets all conversation state
  /// 4. Clears the transcript
  Future<void> endCall() async {
    if (!_isCallActive) return;
    
    _setLoading(true);
    
    try {
      // Call native Android method to stop conversation
      final result = await _channel.invokeMethod('stopConversation');
      debugPrint('🛑 Stop conversation result: $result');
      
      // Reset all state
      _isCallActive = false;
      _isMuted = false;
      _conversationId = null;
      _setLoading(false);
      _setCallStatus('idle');
      _clearTranscript();
      
    } catch (e) {
      debugPrint('❌ Error ending call: $e');
      _setLoading(false);
    }
  }

  /// Toggles the microphone mute state
  /// 
  /// Note: This currently only updates the UI state. Full mute functionality
  /// would need to be implemented in the native Android SDK.
  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint('🎤 Mute toggled: $_isMuted');
    notifyListeners();
  }

  /// Sends a text message to the agent during an active conversation
  /// 
  /// This allows sending text input in addition to voice input.
  /// The message will be added to the transcript and sent to the agent.
  /// 
  /// [message] The text message to send to the agent
  Future<void> sendMessage(String message) async {
    if (!_isCallActive) return;
    
    try {
      // Call native Android method to send message
      final result = await _channel.invokeMethod('sendMessage', {
        'message': message,
      });
      debugPrint('💬 Send message result: $result');
      
      // Add to transcript as user message
      _addTranscriptMessage(message, true);
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
    }
  }

  /// Processes incoming messages from the native ElevenLabs SDK
  /// 
  /// Parses JSON messages and extracts relevant content for the transcript.
  /// Handles different message types:
  /// - user_transcript: User speech transcription
  /// - agent_response: Agent text responses
  /// - agent_response_correction: Corrections to previous responses
  /// - ping: Connection keep-alive (ignored)
  /// - interruption: Conversation interruption events
  /// 
  /// [source] The source of the message (usually 'ai' for agent messages)
  /// [message] The raw JSON message from the native SDK
  void _handleMessage(String source, String message) {
    debugPrint('🔍 Processing message from $source');
    
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final messageType = data['type'] as String?;
      
      debugPrint('📝 Message type: $messageType');
      
      switch (messageType) {
        case 'user_transcript':
          _handleUserTranscript(data);
          break;
        case 'agent_response':
          _handleAgentResponse(data);
          break;
        case 'agent_response_correction':
          _handleAgentResponseCorrection(data);
          break;
        case 'ping':
          // Ignore ping messages - they're just for keeping connection alive
          debugPrint('🏓 Ping ignored');
          break;
        case 'interruption':
          debugPrint('⚠️ Conversation interrupted');
          break;
        default:
          debugPrint('❓ Unhandled message type: $messageType');
      }
    } catch (e) {
      debugPrint('❌ Error parsing message: $e');
    }
  }

  /// Handles user speech transcription events
  void _handleUserTranscript(Map<String, dynamic> data) {
    final transcriptEvent = data['user_transcription_event'] as Map<String, dynamic>?;
    if (transcriptEvent != null) {
      final transcript = transcriptEvent['user_transcript'] as String?;
      if (transcript != null && transcript.trim().isNotEmpty) {
        debugPrint('👤 User said: $transcript');
        _addTranscriptMessage(transcript.trim(), true);
      }
    }
  }

  /// Handles agent text response events
  void _handleAgentResponse(Map<String, dynamic> data) {
    final responseEvent = data['agent_response_event'] as Map<String, dynamic>?;
    if (responseEvent != null) {
      final response = responseEvent['agent_response'] as String?;
      if (response != null && response.trim().isNotEmpty) {
        final cleanResponse = response.trim();
        debugPrint('🤖 Agent said: $cleanResponse');
        _addTranscriptMessage(cleanResponse, false);
      }
    }
  }

  /// Handles agent response correction events
  void _handleAgentResponseCorrection(Map<String, dynamic> data) {
    final correctionEvent = data['agent_response_correction_event'] as Map<String, dynamic>?;
    if (correctionEvent != null) {
      final correction = correctionEvent['corrected_agent_response'] as String?;
      if (correction != null && correction.trim().isNotEmpty) {
        // Replace the last agent message with the correction
        if (_transcript.isNotEmpty && !_transcript.last.isUser) {
          _transcript.removeLast();
        }
        final cleanCorrection = correction.trim();
        debugPrint('🔄 Agent correction: $cleanCorrection');
        _addTranscriptMessage(cleanCorrection, false);
      }
    }
  }

  /// Handles conversation mode changes from the native SDK
  /// 
  /// Updates the UI status based on whether the agent is listening or speaking.
  /// This helps provide visual feedback to the user about conversation state.
  /// 
  /// [mode] The new mode ('listening', 'speaking', etc.)
  void _handleModeChange(String mode) {
    debugPrint('🔄 Mode changed: $mode');
    switch (mode) {
      case 'listening':
        _setCallStatus('listening');
        break;
      case 'speaking':
        _setCallStatus('processing');
        break;
      default:
        _setCallStatus('active');
    }
  }

  /// Handles connection status changes from the native SDK
  /// 
  /// Updates the conversation state based on connection status.
  /// 
  /// [status] The new status ('connected', 'connecting', 'disconnected')
  void _handleStatusChange(String status) {
    debugPrint('📡 Status changed: $status');
    switch (status) {
      case 'connected':
        _setCallStatus('active');
        break;
      case 'connecting':
        _setCallStatus('connecting');
        break;
      case 'disconnected':
        _isCallActive = false;
        _setCallStatus('idle');
        break;
    }
  }

  /// Updates the loading state and notifies UI listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Updates the call status and notifies UI listeners
  void _setCallStatus(String status) {
    _callStatus = status;
    notifyListeners();
  }

  /// Adds a new message to the conversation transcript
  /// 
  /// [text] The message content
  /// [isUser] Whether the message is from the user (true) or agent (false)
  void _addTranscriptMessage(String text, bool isUser) {
    debugPrint('📝 Adding to transcript: $text (user: $isUser)');
    _transcript.add(TranscriptMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Clears all messages from the conversation transcript
  void _clearTranscript() {
    _transcript.clear();
    notifyListeners();
  }

  /// Cleans up resources when the service is disposed
  @override
  void dispose() {
    // Ensure any active conversation is properly closed
    if (_isCallActive) {
      endCall();
    }
    super.dispose();
  }
}