package com.example.ditto_plugin

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import live.ditto.*
import live.ditto.android.DefaultAndroidDittoDependencies
import live.ditto.transports.DittoSyncPermissions

/** DittoPlugin */
class DittoPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var ditto: Ditto
  private lateinit var binding: FlutterPlugin.FlutterPluginBinding
  private val eventSink = mutableListOf<EventChannel.EventSink?>()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.d("DittoPlugin", "onAttachedToEngine called")
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ditto_plugin")
    channel.setMethodCallHandler(this)
    binding = flutterPluginBinding

    // Khởi tạo EventChannel cho streamAllMessages
    val eventChannel = EventChannel(binding.binaryMessenger, "ditto_plugin/chat")
    eventChannel.setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
          Log.d("DittoPlugin", "EventChannel onListen called")
          eventSink.add(events)
          startObservingMessages()
        }

        override fun onCancel(arguments: Any?) {
          Log.d("DittoPlugin", "EventChannel onCancel called")
          eventSink.forEach { it?.endOfStream() }
          eventSink.clear()
        }
      }
    )
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    Log.d("DittoPlugin", "onMethodCall called, method: ${call.method}")
    when (call.method) {
      "initializeDitto" -> initializeDitto(call, result)
      "sendMessage" -> sendMessage(call)
      "deleteMessage" -> deleteMessage(call, result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d("DittoPlugin", "onDetachedFromEngine called")
    channel.setMethodCallHandler(null)
  }

  private fun initializeDitto(call: MethodCall, result: Result) {
    Log.d("DittoPlugin", "initializeDitto called")
    val appId = call.argument<String>("appId")
    val token = call.argument<String>("token")

    if (appId == null || token == null) {
      result.error("ERROR", "AppId and Token cannot be empty", null)
      return
    }

    val androidDependencies = DefaultAndroidDittoDependencies(binding.applicationContext)
    ditto = Ditto(androidDependencies, DittoIdentity.OnlinePlayground(
      androidDependencies,
      appId,
      token,
      enableDittoCloudSync = true
    ))

    DittoLogger.minimumLogLevel = DittoLogLevel.INFO
    ditto.startSync()
    ditto.disableSyncWithV3()

    Log.d("DittoPlugin", "Ditto initialized with App ID: $appId, Token: $token")
    result.success(true)
  }

  private fun sendMessage(call: MethodCall) {
    Log.d("DittoPlugin", "sendMessage called")
    val documentId = call.argument<String>("messageId") ?: ""
    val content = call.argument<String>("content") ?: ""
    val createdAt = call.argument<String>("createdAt") ?: ""
    val senderName = call.argument<String>("senderName") ?: ""

    ditto.store.collection("chat").upsert(
      mapOf(
        "id" to documentId,
        "content" to content,
        "createdAt" to createdAt,
        "senderName" to senderName,
        "isDeleted" to false
      )
    )
    Log.d("DittoPlugin", "Message saved: messageId: $documentId, content: $content, createdAt: $createdAt, senderName: $senderName")
  }

  private fun deleteMessage(call: MethodCall, result: Result) {
    Log.d("DittoPlugin", "deleteMessage called")
    val messageId = call.argument<String>("messageId") ?: ""
    if (messageId.isBlank()) {
      result.error("ERROR", "Missing messageId", null)
      return
    }
    ditto.store.collection("chat").findById(messageId).remove()
    Log.d("DittoPlugin", "Message deleted: messageId: $messageId")
  }

  private fun startObservingMessages() {
    val messagesCollection = ditto.store["chat"]
    ditto.sync.registerSubscription("SELECT * FROM chat")

    messagesCollection
      .find("!isDeleted")
      .sort("createdOn", DittoSortDirection.Ascending)
      .observeLocal { docs, _ ->
        try {
          Log.d("DittoPlugin", "streamAllMessages observeLocal called, docs: $docs")
          val jsonString = StringBuilder().apply {
            append("[")
            docs.forEachIndexed { index, document ->
              append("{")
              append("\"id\": \"${document.id}\",")
              append("\"content\": \"${document.value["content"]}\",")
              append("\"createdAt\": \"${document.value["createdAt"]}\",")
              append("\"senderName\": \"${document.value["senderName"]}\"")
              append("}")
              if (index < docs.size - 1) {
                append(",")
              }
            }
            append("]")
          }.toString()

          Handler(Looper.getMainLooper()).post {
            eventSink.forEach { it?.success(jsonString) }
          }
        } catch (e: Exception) {
          Log.e("DittoPlugin", "Error in streamAllMessages observeLocal: ", e)
          eventSink.forEach { it?.error("ERROR", e.message, null) }
        }
      }
  }
}