import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Interactive call button with state-aware styling and animations
/// 
/// This widget provides the primary interaction point for starting and ending
/// voice conversations. It features sophisticated visual feedback, smooth
/// animations, and clear state indication to guide user interactions.
/// 
/// ## Features
/// 
/// - **State-Aware Styling**: Visual appearance changes based on call status
/// - **Touch Feedback**: Satisfying scale animation on press/release
/// - **Loading States**: Spinner animation during connection/disconnection
/// - **Accessibility**: Proper touch targets and visual contrast
/// - **Color Coding**: Blue for start, red for end call actions
/// 
/// ## Visual States
/// 
/// | State | Color | Icon | Animation |
/// |-------|-------|------|-----------|
/// | **Ready to Call** | Blue | Phone | Scale on touch |
/// | **Connecting** | Blue | Spinner | Rotation |
/// | **Active Call** | Red | Phone End | Scale on touch |
/// | **Disconnecting** | Red | Spinner | Rotation |
/// 
/// ## Usage
/// 
/// ```dart
/// CallButton(
///   isCallActive: voiceService.isCallActive,
///   isLoading: voiceService.isLoading,
///   onPressed: () => handleCallToggle(),
/// )
/// ```
/// 
/// The button automatically handles visual state transitions and provides
/// appropriate feedback for all user interactions.
class CallButton extends StatefulWidget {
  /// Whether a voice conversation is currently active
  /// 
  /// Controls the button's visual state:
  /// - `false`: Blue button with call icon (ready to start)
  /// - `true`: Red button with end call icon (ready to end)
  final bool isCallActive;
  
  /// Whether the button is in a loading state
  /// 
  /// When `true`, displays a spinner instead of the normal icon
  /// and disables touch interactions to prevent multiple requests.
  final bool isLoading;
  
  /// Callback function executed when the button is pressed
  /// 
  /// This should handle the logic for starting or ending conversations
  /// based on the current [isCallActive] state.
  final VoidCallback onPressed;
  
  /// Creates an interactive call button
  /// 
  /// All parameters are required to ensure proper state management
  /// and user interaction handling.
  const CallButton({
    super.key,
    required this.isCallActive,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isCallActive 
                    ? AppTheme.accentRed 
                    : AppTheme.primaryBlue,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isCallActive 
                        ? AppTheme.accentRed 
                        : AppTheme.primaryBlue).withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Icon(
                      widget.isCallActive ? Icons.call_end : Icons.call,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}