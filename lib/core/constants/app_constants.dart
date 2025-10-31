/// Application-wide constants and configuration values
/// 
/// This class centralizes all constant values used throughout the application,
/// including environment variable keys, UI dimensions, animation durations,
/// and other configuration parameters. This approach ensures consistency
/// and makes it easy to modify values across the entire application.
/// 
/// ## Usage Examples
/// 
/// ```dart
/// // Environment variables
/// final agentId = dotenv.env[AppConstants.elevenLabsAgentIdEnv];
/// 
/// // UI spacing
/// Padding(padding: EdgeInsets.all(AppConstants.defaultPadding))
/// 
/// // Animations
/// AnimationController(duration: AppConstants.shortAnimation)
/// ```
class AppConstants {
  /// Private constructor to prevent instantiation
  /// This class should only be used for static constant access
  AppConstants._();
  
  // ========================================
  // Environment Variable Keys
  // ========================================
  
  /// Environment variable key for ElevenLabs Agent ID
  /// 
  /// This should be set in your .env file:
  /// ```env
  /// ELEVENLABS_AGENT_ID=ag_your_agent_id_here
  /// ```
  static const String elevenLabsAgentIdEnv = 'ELEVENLABS_AGENT_ID';
  
  /// Environment variable key for ElevenLabs API Key
  /// 
  /// This should be set in your .env file:
  /// ```env
  /// ELEVENLABS_API_KEY=sk_your_api_key_here
  /// ```
  static const String elevenLabsApiKeyEnv = 'ELEVENLABS_API_KEY';
  

  
  // ========================================
  // UI Layout Constants
  // ========================================
  
  /// Standard padding used throughout the app (16.0 logical pixels)
  /// 
  /// Used for:
  /// - Screen edge padding
  /// - Widget spacing
  /// - Card content padding
  static const double defaultPadding = 16.0;
  
  /// Large padding for major layout sections (32.0 logical pixels)
  /// 
  /// Used for:
  /// - Section separators
  /// - Major component spacing
  /// - Screen header/footer padding
  static const double largePadding = 32.0;
  
  /// Standard border radius for rounded corners (12.0 logical pixels)
  /// 
  /// Applied to:
  /// - Cards and containers
  /// - Buttons and interactive elements
  /// - Modal dialogs
  static const double borderRadius = 12.0;
  
  // ========================================
  // Animation Durations
  // ========================================
  
  /// Short animation duration for quick transitions (300ms)
  /// 
  /// Used for:
  /// - Button press feedback
  /// - Small UI state changes
  /// - Quick fade in/out effects
  static const Duration shortAnimation = Duration(milliseconds: 300);
  
  /// Medium animation duration for standard transitions (500ms)
  /// 
  /// Used for:
  /// - Screen transitions
  /// - Modal appearances
  /// - Loading state changes
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  
  /// Long animation duration for complex animations (800ms)
  /// 
  /// Used for:
  /// - Complex state transitions
  /// - Multi-step animations
  /// - Emphasis effects
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // ========================================
  // Avatar Component Dimensions
  // ========================================
  
  /// Main avatar circle diameter (120.0 logical pixels)
  /// 
  /// The core avatar that displays the user/agent icon
  static const double avatarSize = 120.0;
  
  /// Avatar glow effect outer diameter (160.0 logical pixels)
  /// 
  /// The animated glow ring that appears around the avatar
  /// during active conversations
  static const double avatarGlowSize = 160.0;
  
  // ========================================
  // Audio Visualizer Configuration
  // ========================================
  
  /// Number of bars in the audio visualizer (20)
  /// 
  /// Controls the resolution of the audio visualization.
  /// More bars = smoother visualization but higher CPU usage.
  static const int visualizerBars = 20;
  
  /// Width of each visualizer bar (4.0 logical pixels)
  static const double visualizerBarWidth = 4.0;
  
  /// Spacing between visualizer bars (2.0 logical pixels)
  static const double visualizerBarSpacing = 2.0;
  
  /// Maximum height for visualizer bars (60.0 logical pixels)
  /// 
  /// Bars will animate between 0 and this height based on audio levels
  static const double visualizerMaxHeight = 60.0;
}