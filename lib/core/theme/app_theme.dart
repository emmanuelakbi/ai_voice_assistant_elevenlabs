import 'package:flutter/material.dart';

/// Application theme configuration and design system
/// 
/// This class defines the complete visual design system for the ElevenLabs
/// Voice Chat app. It provides a cohesive dark theme with carefully
/// chosen colors, typography, and component styles that create a modern,
/// professional appearance optimized for voice interaction interfaces.
/// 
/// ## Design Philosophy
/// 
/// The theme follows these principles:
/// - **Dark-first design**: Reduces eye strain during extended voice sessions
/// - **High contrast**: Ensures accessibility and readability
/// - **Minimal and clean**: Simple interface that focuses on conversation
/// - **Professional appearance**: Suitable for business and personal use
/// - **No unnecessary effects**: Clean design without excessive shadows or gradients
/// 
/// ## Usage
/// 
/// ```dart
/// MaterialApp(
///   theme: AppTheme.darkTheme,
///   // ...
/// )
/// 
/// // Access colors directly
/// Container(color: AppTheme.primaryBlue)
/// Text('Hello', style: TextStyle(color: AppTheme.textPrimary))
/// ```
class AppTheme {
  /// Private constructor to prevent instantiation
  AppTheme._();
  
  // ========================================
  // Color Palette
  // ========================================
  
  /// Primary brand color - clean blue for interactive elements
  /// 
  /// Used for:
  /// - Call buttons and primary actions
  /// - Avatar glow effects
  /// - Active state indicators
  /// - Links and interactive text
  /// 
  /// Hex: #3B82F6 | RGB: (59, 130, 246) - Clean modern blue
  static const Color primaryBlue = Color(0xFF3B82F6);
  
  /// Main background color - deep black for minimal distraction
  /// 
  /// Used for:
  /// - Screen backgrounds
  /// - Main app scaffold
  /// - Full-screen overlays
  /// 
  /// Hex: #0A0A0A | RGB: (10, 10, 10)
  static const Color darkBackground = Color(0xFF0A0A0A);
  
  /// Card and container background - subtle dark gray
  /// 
  /// Used for:
  /// - Cards and elevated surfaces
  /// - Modal dialogs
  /// - Input fields and containers
  /// - Transcript background
  /// 
  /// Hex: #1A1A1A | RGB: (26, 26, 26)
  static const Color cardBackground = Color(0xFF1A1A1A);
  
  /// Primary text color - pure white for maximum contrast
  /// 
  /// Used for:
  /// - Main headings and titles
  /// - Important body text
  /// - Button labels
  /// - Active state text
  static const Color textPrimary = Colors.white;
  
  /// Secondary text color - medium gray for supporting content
  /// 
  /// Used for:
  /// - Subtitles and descriptions
  /// - Timestamps and metadata
  /// - Placeholder text
  /// - Inactive state indicators
  /// 
  /// Hex: #888888 | RGB: (136, 136, 136)
  static const Color textSecondary = Color(0xFF888888);
  
  /// Accent red color for warnings and destructive actions
  /// 
  /// Used for:
  /// - End call button
  /// - Error messages
  /// - Warning indicators
  /// - Mute state (when active)
  /// 
  /// Hex: #EF4444 | RGB: (239, 68, 68) - Modern red
  static const Color accentRed = Color(0xFFEF4444);
  
  // ========================================
  // Theme Configuration
  // ========================================
  
  /// Complete dark theme configuration for the application
  /// 
  /// This theme provides a comprehensive styling system that covers:
  /// - Typography hierarchy with proper contrast ratios
  /// - Button styles optimized for touch interaction
  /// - Icon styling consistent with the overall design
  /// - Color scheme that reduces eye strain
  /// 
  /// The theme is designed to be accessible and follows Material Design
  /// guidelines while maintaining a unique visual identity.
  static ThemeData get darkTheme {
    return ThemeData(
      // Core theme properties
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      cardColor: cardBackground,
      
      // Typography system with proper hierarchy
      textTheme: const TextTheme(
        // Large headlines for main titles (28px, bold)
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5, // Tighter spacing for large text
        ),
        
        // Medium headlines for section titles (24px, semi-bold)
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
        
        // Large body text for important content (16px, regular)
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5, // Improved line height for readability
        ),
        
        // Medium body text for secondary content (14px, regular)
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.4,
        ),
      ),
      
      // Elevated button styling for primary actions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textPrimary,
          elevation: 0, // Flat design for modern appearance
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Pill-shaped buttons
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Icon styling consistent with text colors
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // App bar styling (if used)
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card styling for elevated surfaces
      cardTheme: const CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(8),
      ),
      
      // Dialog styling for modals and alerts
      dialogTheme: const DialogThemeData(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: textSecondary,
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}