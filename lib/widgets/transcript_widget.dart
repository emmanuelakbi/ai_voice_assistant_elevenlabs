import 'package:flutter/material.dart';
import '../services/elevenlabs_native_service.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Real-time conversation transcript display with advanced message handling
/// 
/// This widget provides a comprehensive view of the ongoing voice conversation,
/// displaying messages from both the user and AI assistant with distinct styling,
/// timestamps, and automatic scrolling behavior.
/// 
/// ## Features
/// 
/// - **Real-time Updates**: Automatically displays new messages as they arrive
/// - **Auto-scrolling**: Smoothly scrolls to show the latest messages
/// - **Message Differentiation**: Distinct styling for user vs assistant messages
/// - **Timestamps**: Precise time display for each message
/// - **Message Count**: Header shows total number of messages
/// - **Empty State**: Helpful placeholder when no messages exist
/// - **Responsive Design**: Adapts to different screen sizes and orientations
/// 
/// ## Message Layout
/// 
/// ```
/// ┌─────────────────────────────────────┐
/// │ 🗨️ Live Transcript    5 messages    │
/// ├─────────────────────────────────────┤
/// │ 👤 You                    14:32:15  │
/// │ ┌─────────────────────────────────┐ │
/// │ │ Hello, how are you today?       │ │
/// │ └─────────────────────────────────┘ │
/// │                                     │
/// │ 🤖 Assistant              14:32:18  │
/// │ ┌─────────────────────────────────┐ │
/// │ │ I'm doing well, thank you!      │ │
/// │ └─────────────────────────────────┘ │
/// └─────────────────────────────────────┘
/// ```
/// 
/// ## Usage
/// 
/// ```dart
/// TranscriptWidget(
///   transcript: voiceService.transcript,
/// )
/// ```
/// 
/// The widget automatically handles all message display logic and scrolling
/// behavior based on the provided transcript list.
class TranscriptWidget extends StatefulWidget {
  /// List of conversation messages to display
  /// 
  /// Each [TranscriptMessage] contains:
  /// - Message text content
  /// - Sender identification (user vs assistant)
  /// - Timestamp for when the message was created
  /// 
  /// The list is expected to be in chronological order, with newer
  /// messages at the end. The widget will automatically scroll to
  /// show the most recent messages.
  final List<TranscriptMessage> transcript;
  
  /// Creates a transcript display widget
  /// 
  /// The [transcript] parameter is required and should contain the
  /// complete conversation history to display.
  const TranscriptWidget({
    super.key,
    required this.transcript,
  });

  @override
  State<TranscriptWidget> createState() => _TranscriptWidgetState();
}

class _TranscriptWidgetState extends State<TranscriptWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(TranscriptWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll to bottom when new messages arrive
    if (widget.transcript.length != oldWidget.transcript.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: AppConstants.shortAnimation,
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transcript.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardBackground.withValues(alpha: 0.4),
              AppTheme.cardBackground.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 32,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start a conversation',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your conversation will appear here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBackground.withValues(alpha: 0.4),
            AppTheme.cardBackground.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chat_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Live Transcript',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.transcript.length} messages',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: widget.transcript.length,
              itemBuilder: (context, index) {
                final message = widget.transcript[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(TranscriptMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: message.isUser 
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.6),
                        AppTheme.primaryBlue.withValues(alpha: 0.4),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        AppTheme.textSecondary.withValues(alpha: 0.6),
                        AppTheme.textSecondary.withValues(alpha: 0.4),
                      ],
                    ),
              boxShadow: [
                BoxShadow(
                  color: (message.isUser 
                      ? AppTheme.primaryBlue 
                      : AppTheme.textSecondary).withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              message.isUser ? Icons.person_rounded : Icons.psychology_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender and timestamp
                Row(
                  children: [
                    Text(
                      message.isUser ? 'You' : 'Assistant',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: message.isUser 
                            ? AppTheme.primaryBlue
                            : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(message.timestamp),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 2),
                
                // Message text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: message.isUser 
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withValues(alpha: 0.15),
                              AppTheme.primaryBlue.withValues(alpha: 0.1),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              AppTheme.cardBackground.withValues(alpha: 0.6),
                              AppTheme.cardBackground.withValues(alpha: 0.4),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: message.isUser 
                          ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                          : AppTheme.textSecondary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}