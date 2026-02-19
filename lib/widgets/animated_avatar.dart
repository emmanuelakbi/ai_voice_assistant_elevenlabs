import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class AnimatedAvatar extends StatefulWidget {
  final bool isActive;
  
  final String status;
  
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
  late AnimationController _pulseController;
  
  late AnimationController _glowController;
  
  late Animation<double> _pulseAnimation;
  
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive ||
        widget.status != oldWidget.status) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isActive) {
      _glowController.repeat(reverse: true);
      
      if (widget.status == 'listening') {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    } else {
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
