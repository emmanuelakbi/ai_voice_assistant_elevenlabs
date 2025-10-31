import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

/// Animated avatar widget with dynamic visual feedback for voice conversations
/// 
/// This widget serves as the central visual element of the voice assistant interface,
/// providing real-time feedback about the conversation state through sophisticated
/// animations and visual effects.
/// 
/// ## Features
/// 
/// - **Pulsing Animation**: Avatar scales up/down when actively listening
/// - **Glow Effects**: Outer ring glows and pulses during active conversations
/// - **State-Responsive**: Visual appearance changes based on conversation status
/// - **Smooth Transitions**: All animations use easing curves for natural feel
/// - **Performance Optimized**: Efficient animation controllers with proper disposal
/// 
/// ## Visual States
/// 
/// | State | Avatar | Glow | Animation |
/// |-------|--------|------|-----------|
/// | **Idle** | Static blue circle with mic icon | None | None |
/// | **Connected** | Static blue circle with mic icon | Gentle pulsing | Glow fade in/out |
/// | **Listening** | Pulsing scale with mic icon | Active glow | Scale + glow animations |
/// | **Processing** | Static blue circle with mic icon | Steady glow | Glow only |
/// 
/// ## Usage
/// 
/// ```dart
/// AnimatedAvatar(
///   isActive: voiceService.isCallActive,
///   status: voiceService.callStatus,
/// )
/// ```
/// 
/// The widget automatically manages its animation state based on the provided
/// parameters and handles all animation lifecycle management internally.
class AnimatedAvatar extends StatefulWidget {
  /// Whether the voice conversation is currently active
  /// 
  /// When `true`, enables glow animations and visual feedback.
  /// When `false`, shows static avatar with no animations.
  final bool isActive;
  
  /// Current conversation status for fine-grained animation control
  /// 
  /// Supported values:
  /// - `'idle'`: No conversation, static appearance
  /// - `'connecting'`: Connection in progress, gentle glow
  /// - `'active'`: Connected and ready, steady glow
  /// - `'listening'`: Actively listening to user, pulsing + glow
  /// - `'processing'`: Agent processing response, steady glow
  final String status;
  
  /// Creates an animated avatar widget
  /// 
  /// Both [isActive] and [status] are required to determine the appropriate
  /// visual state and animations to display.
  const AnimatedAvatar({
    super.key,
    required this.isActive,
    required this.status,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with TickerProviderStateMixin {
  /// Animation controller for avatar scaling (pulse effect)
  /// 
  /// Controls the subtle scale animation that occurs when the avatar
  /// is actively listening to user speech.
  late AnimationController _pulseController;
  
  /// Animation controller for glow effect intensity
  /// 
  /// Manages the outer glow ring that appears around the avatar
  /// during active conversations.
  late AnimationController _glowController;
  
  /// Scale animation for the main avatar circle
  /// 
  /// Animates between 1.0 (normal size) and 1.1 (slightly larger)
  /// to create a subtle "breathing" effect during listening state.
  late Animation<double> _pulseAnimation;
  
  /// Opacity animation for the glow effect
  /// 
  /// Controls the intensity of the outer glow ring, animating
  /// between 0.3 (subtle) and 1.0 (full intensity).
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize pulse animation for avatar scaling
    // Uses medium duration for natural breathing effect
    _pulseController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,  // Normal size
      end: 1.1,    // 10% larger for subtle effect
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut, // Smooth acceleration/deceleration
    ));
    
    // Initialize glow animation for outer ring effect
    // Longer duration for slower, more mesmerizing effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,  // Subtle glow
      end: 1.0,    // Full intensity
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animations when widget properties change
    if (widget.isActive != oldWidget.isActive ||
        widget.status != oldWidget.status) {
      _updateAnimations();
    }
  }

  /// Updates animation states based on current widget properties
  /// 
  /// This method orchestrates the various animations based on the conversation
  /// state, ensuring smooth transitions between different visual modes.
  /// 
  /// Animation Logic:
  /// - **Active Conversation**: Glow animation runs continuously
  /// - **Listening State**: Both glow and pulse animations active
  /// - **Other Active States**: Only glow animation active
  /// - **Inactive**: All animations stopped and reset
  void _updateAnimations() {
    if (widget.isActive) {
      // Start glow animation for any active conversation
      _glowController.repeat(reverse: true);
      
      // Add pulse animation specifically for listening state
      if (widget.status == 'listening') {
        _pulseController.repeat(reverse: true);
      } else {
        // Stop pulse for other active states (connected, processing)
        _pulseController.stop();
        _pulseController.reset();
      }
    } else {
      // Stop all animations when conversation is inactive
      _glowController.stop();
      _pulseController.stop();
      _glowController.reset();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          width: AppConstants.avatarGlowSize,
          height: AppConstants.avatarGlowSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: _glowAnimation.value * 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: _glowAnimation.value * 0.2),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: AppConstants.avatarSize,
                height: AppConstants.avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue,
                  border: Border.all(
                    color: widget.isActive 
                        ? AppTheme.primaryBlue
                        : AppTheme.primaryBlue.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.mic,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }
}