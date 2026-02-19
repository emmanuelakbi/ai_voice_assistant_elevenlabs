import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/app_constants.dart';

class TranscriptMessage {
  final String text;
  
  final bool isUser;
  
  final DateTime timestamp;
  
  TranscriptMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ElevenLabsNativeService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('elevenlabs_native');
  
  bool _isCallActive = false;
  bool _isLoading = false;
  bool _isMuted = false;
  String _callStatus = 'idle';
  final List<TranscriptMessage> _transcript = [];
  String? _conversationId;
  
  
  bool get isCallActive => _isCallActive;
  
  bool get isLoading => _isLoading;
  
  bool get isMuted => _isMuted;
  
  String get callStatus => _callStatus;
  
  List<TranscriptMessage> get transcript => List.unmodifiable(_transcript);
  
  String? get conversationId => _conversationId;
  
  String get _agentId => dotenv.env[AppConstants.elevenLabsAgentIdEnv] ?? '';

  ElevenLabsNativeService() {
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onConnect':
          _conversationId = call.arguments as String?;
          _isCallActive = true;
          _setLoading(false);
          _setCallStatus('active');
          debugPrint('✅ Connected to conversation: $_conversationId');
          break;
          
        case 'onMessage':
          final data = call.arguments as Map<dynamic, dynamic>;
          final source = data['source'] as String;
          final message = data['message'] as String;
          _handleMessage(source, message);
          break;
          
        case 'onModeChange':
          final mode = call.arguments as String;
          _handleModeChange(mode);
          break;
          
        case 'onStatusChange':
          final status = call.arguments as String;
          _handleStatusChange(status);
          break;
      }
    });
  }

  Future<void> initialize() async {
    if (_agentId.isEmpty) {
      throw Exception('ElevenLabs Agent ID not found in environment variables. '
          'Please check your .env file contains ELEVENLABS_AGENT_ID.');
    }
  }

  Future<void> startCall() async {
    if (_isCallActive) return;
    
    _setLoading(true);
    
    try {
      await initialize();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      Exception? lastException;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          debugPrint('🔄 Starting conversation attempt $attempt/3');
          
          final result = await _channel.invokeMethod('startConversation', {
            'agentId': _agentId,
            'userId': 'flutter_user_${DateTime.now().millisecondsSinceEpoch}',
          });
          
          debugPrint('🚀 Start conversation result: $result');
          _setCallStatus('connecting');
          return;
          
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          debugPrint('❌ Attempt $attempt failed: $e');
          
          if (attempt < 3) {
            await Future.delayed(Duration(milliseconds: 500 * attempt));
          }
        }
      }
      
      throw lastException ?? Exception('Failed to start conversation after 3 attempts');
      
    } catch (e) {
      _setLoading(false);
      _setCallStatus('error');
      debugPrint('❌ Error starting call: $e');
      rethrow;
    }
  }

  Future<void> endCall() async {
    if (!_isCallActive) return;
    
    _setLoading(true);
    
    try {
      final result = await _channel.invokeMethod('stopConversation');
      debugPrint('🛑 Stop conversation result: $result');
      
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

  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint('🎤 Mute toggled: $_isMuted');
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (!_isCallActive) return;
    
    try {
      final result = await _channel.invokeMethod('sendMessage', {
        'message': message,
      });
      debugPrint('💬 Send message result: $result');
      
      _addTranscriptMessage(message, true);
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
    }
  }

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

  void _handleAgentResponseCorrection(Map<String, dynamic> data) {
    final correctionEvent = data['agent_response_correction_event'] as Map<String, dynamic>?;
    if (correctionEvent != null) {
      final correction = correctionEvent['corrected_agent_response'] as String?;
      if (correction != null && correction.trim().isNotEmpty) {
        if (_transcript.isNotEmpty && !_transcript.last.isUser) {
          _transcript.removeLast();
        }
        final cleanCorrection = correction.trim();
        debugPrint('🔄 Agent correction: $cleanCorrection');
        _addTranscriptMessage(cleanCorrection, false);
      }
    }
  }

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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCallStatus(String status) {
    _callStatus = status;
    notifyListeners();
  }

  void _addTranscriptMessage(String text, bool isUser) {
    debugPrint('📝 Adding to transcript: $text (user: $isUser)');
    _transcript.add(TranscriptMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void _clearTranscript() {
    _transcript.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isCallActive) {
      endCall();
    }
    super.dispose();
  }
}
