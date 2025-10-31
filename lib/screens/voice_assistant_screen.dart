import 'package:flutter/material.dart';
import '../services/elevenlabs_native_service.dart';
import '../widgets/animated_avatar.dart';
import '../widgets/call_button.dart';
import '../widgets/transcript_widget.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Main voice assistant interface screen
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  /// Service for managing ElevenLabs voice conversations
  late ElevenLabsNativeService _voiceService;

  @override
  void initState() {
    super.initState();
    // Initialize the ElevenLabs service for voice conversations
    _voiceService = ElevenLabsNativeService();
  }

  /// Handles the main call button press (start/stop conversation)
  Future<void> _handleCallButtonPress() async {
    try {
      if (_voiceService.isCallActive) {
        await _voiceService.endCall();
      } else {
        await _voiceService.startCall();
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppTheme.accentRed.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppTheme.accentRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Connection Error',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }

  /// Get status text based on call state
  String _getStatusText() {
    if (_voiceService.isLoading) {
      return 'Connecting...';
    }
    
    switch (_voiceService.callStatus) {
      case 'idle':
        return 'Tap to start conversation';
      case 'connecting':
        return 'Connecting...';
      case 'active':
        return 'Connected';
      case 'listening':
        return 'Listening...';
      case 'processing':
        return 'Processing...';
      case 'error':
        return 'Connection error';
      default:
        return 'Ready';
    }
  }

  /// Get status indicator color based on call state
  Color _getStatusColor() {
    if (_voiceService.isLoading) {
      return AppTheme.primaryBlue;
    }
    
    switch (_voiceService.callStatus) {
      case 'idle':
        return AppTheme.textSecondary;
      case 'connecting':
        return AppTheme.primaryBlue;
      case 'active':
        return const Color(0xFF10B981); // Green
      case 'listening':
        return AppTheme.primaryBlue;
      case 'processing':
        return AppTheme.primaryBlue;
      case 'error':
        return AppTheme.accentRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _voiceService,
        builder: (context, child) {
          return Container(
            color: AppTheme.darkBackground,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    
                    const Spacer(flex: 2),
                    
                    // Animated Avatar
                    AnimatedAvatar(
                      isActive: _voiceService.isCallActive,
                      status: _voiceService.callStatus,
                    ),
                    
                    const SizedBox(height: AppConstants.largePadding),
                    
                    // Title and Status
                    _buildTitleSection(),
                    
                    const SizedBox(height: AppConstants.largePadding),
                    
                    // Transcript (always show when call is active)
                    if (_voiceService.isCallActive)
                      TranscriptWidget(transcript: _voiceService.transcript),
                    
                    const Spacer(flex: 2),
                    
                    // Call Button
                    CallButton(
                      isCallActive: _voiceService.isCallActive,
                      isLoading: _voiceService.isLoading,
                      onPressed: _handleCallButtonPress,
                    ),
                    
                    const SizedBox(height: AppConstants.largePadding),
                    
                    // Mute Button (only show when call is active)
                    if (_voiceService.isCallActive) _buildMuteButton(),
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            // Add menu functionality if needed
          },
          icon: const Icon(Icons.menu),
          color: AppTheme.textSecondary,
        ),
        Text(
          'Voice Chat',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () {
            // Add settings functionality if needed
          },
          icon: const Icon(Icons.settings),
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }

  /// Build title and status section
  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Voice Assistant',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: AppConstants.shortAnimation,
          child: Text(
            _getStatusText(),
            key: ValueKey(_getStatusText()),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Build mute button
  Widget _buildMuteButton() {
    return GestureDetector(
      onTap: _voiceService.toggleMute,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _voiceService.isMuted 
              ? AppTheme.accentRed.withValues(alpha: 0.2)
              : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: _voiceService.isMuted 
                ? AppTheme.accentRed
                : AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _voiceService.isMuted ? Icons.mic_off : Icons.mic,
              color: _voiceService.isMuted 
                  ? AppTheme.accentRed 
                  : AppTheme.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _voiceService.isMuted ? 'Unmute' : 'Mute',
              style: TextStyle(
                color: _voiceService.isMuted 
                    ? AppTheme.accentRed 
                    : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}