package com.elevenlabs.voicechat

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.elevenlabs.ConversationClient
import io.elevenlabs.ConversationConfig
import io.elevenlabs.ConversationSession
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * MainActivity - Native Android integration for ElevenLabs Voice Assistant
 * 
 * This activity serves as the critical bridge between Flutter's Dart code and the
 * ElevenLabs Android SDK, enabling seamless real-time voice conversations with AI agents.
 * 
 * ## Core Responsibilities
 * 
 * - **WebSocket Management**: Establishes and maintains persistent connections to ElevenLabs servers
 * - **Audio Processing**: Handles real-time audio recording, streaming, and playback
 * - **Conversation Lifecycle**: Manages the complete flow from connection to disconnection
 * - **Event Forwarding**: Relays all conversation events back to Flutter for UI updates
 * - **Error Handling**: Provides robust error handling and recovery mechanisms
 * 
 * ## Architecture Integration
 * 
 * The activity uses Flutter's method channels for bidirectional communication:
 * 
 * ```
 * Flutter (Dart) ←→ Method Channel ←→ MainActivity (Kotlin) ←→ ElevenLabs SDK
 * ```
 * 
 * ## Method Channel Interface
 * 
 * ### Inbound Methods (Flutter → Native)
 * - `startConversation(agentId, userId)`: Initiates a new voice conversation
 * - `stopConversation()`: Ends the current conversation and cleans up resources
 * - `sendMessage(message)`: Sends a text message during an active conversation
 * 
 * ### Outbound Callbacks (Native → Flutter)
 * - `onConnect(conversationId)`: Notifies successful connection establishment
 * - `onMessage(source, message)`: Forwards all conversation messages and events
 * - `onModeChange(mode)`: Reports conversation mode changes (listening/speaking)
 * - `onStatusChange(status)`: Updates connection status (connected/disconnected)
 * 
 * ## Concurrency Model
 * 
 * The activity uses Kotlin coroutines with the Main dispatcher to ensure all
 * Flutter method channel communications happen on the UI thread, preventing
 * threading issues and ensuring smooth integration.
 * 
 * ## Error Handling
 * 
 * All operations are wrapped in try-catch blocks with proper error reporting
 * back to Flutter through the method channel result callbacks.
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "elevenlabs_native"
        private const val TAG = "ElevenLabs"
    }
    
    private var conversationSession: ConversationSession? = null
    private val coroutineScope = CoroutineScope(Dispatchers.Main)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startConversation" -> {
                    val agentId = call.argument<String>("agentId")
                    val userId = call.argument<String>("userId")
                    
                    if (agentId != null) {
                        startConversation(agentId, userId, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Agent ID is required", null)
                    }
                }
                "stopConversation" -> {
                    stopConversation(result)
                }
                "sendMessage" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
                        sendMessage(message, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Message is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Initiates a new voice conversation with the specified ElevenLabs agent
     * 
     * This method creates a new ConversationSession using the ElevenLabs Android SDK,
     * configures all necessary event callbacks, and starts the WebSocket connection
     * for real-time voice communication.
     * 
     * @param agentId The ElevenLabs agent identifier to connect to
     * @param userId Optional user identifier for conversation tracking
     * @param result Method channel result callback for success/error reporting
     */
    private fun startConversation(agentId: String, userId: String?, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                // Ensure any existing session is properly closed
                conversationSession?.endSession()
                conversationSession = null
                
                // Validate agent ID
                if (agentId.isBlank()) {
                    result.error("INVALID_AGENT_ID", "Agent ID cannot be empty", null)
                    return@launch
                }
                
                Log.d(TAG, "Starting conversation with agent: $agentId")
                
                val config = ConversationConfig(
                    agentId = agentId,
                    userId = userId ?: "flutter_user_${System.currentTimeMillis()}",
                    onConnect = { conversationId ->
                        Log.d(TAG, "Connected: $conversationId")
                        runOnUiThread {
                            try {
                                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                                    .invokeMethod("onConnect", conversationId)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error invoking onConnect", e)
                            }
                        }
                    },
                    onMessage = { source, messageJson ->
                        Log.d(TAG, "Message from $source: $messageJson")
                        runOnUiThread {
                            try {
                                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                                    .invokeMethod("onMessage", mapOf("source" to source, "message" to messageJson))
                            } catch (e: Exception) {
                                Log.e(TAG, "Error invoking onMessage", e)
                            }
                        }
                    },
                    onModeChange = { mode ->
                        Log.d(TAG, "Mode changed: $mode")
                        runOnUiThread {
                            try {
                                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                                    .invokeMethod("onModeChange", mode)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error invoking onModeChange", e)
                            }
                        }
                    },
                    onStatusChange = { status ->
                        Log.d(TAG, "Status changed: $status")
                        runOnUiThread {
                            try {
                                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                                    .invokeMethod("onStatusChange", status)
                            } catch (e: Exception) {
                                Log.e(TAG, "Error invoking onStatusChange", e)
                            }
                        }
                    }
                )

                conversationSession = ConversationClient.startSession(config, this@MainActivity)
                Log.d(TAG, "Conversation session created successfully")
                result.success("Conversation started")
                
            } catch (e: Exception) {
                Log.e(TAG, "Error starting conversation", e)
                val errorMessage = e.message ?: "Failed to start conversation session"
                result.error("CONVERSATION_ERROR", errorMessage, e.toString())
            }
        }
    }

    /**
     * Ends the current voice conversation and cleans up all resources
     * 
     * This method gracefully terminates the active ConversationSession,
     * closes the WebSocket connection, and releases all audio resources.
     * 
     * @param result Method channel result callback for success/error reporting
     */
    private fun stopConversation(result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                conversationSession?.endSession()
                conversationSession = null
                result.success("Conversation stopped")
            } catch (e: Exception) {
                Log.e("ElevenLabs", "Error stopping conversation", e)
                result.error("CONVERSATION_ERROR", e.message, null)
            }
        }
    }

    private fun sendMessage(message: String, result: MethodChannel.Result) {
        try {
            conversationSession?.sendUserMessage(message)
            result.success("Message sent")
        } catch (e: Exception) {
            Log.e("ElevenLabs", "Error sending message", e)
            result.error("MESSAGE_ERROR", e.message, null)
        }
    }

    override fun onDestroy() {
        coroutineScope.launch {
            conversationSession?.endSession()
        }
        super.onDestroy()
    }
}
