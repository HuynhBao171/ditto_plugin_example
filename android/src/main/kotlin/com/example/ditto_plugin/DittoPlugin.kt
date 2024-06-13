package com.example.ditto_plugin

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.example.ditto_plugin.data.Task
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
  private lateinit var tasksSubscription: DittoSubscription
  private val eventSink = mutableListOf<EventChannel.EventSink?>()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.d("DittoPlugin", "onAttachedToEngine called")
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ditto_plugin")
    channel.setMethodCallHandler(this)
    binding = flutterPluginBinding

    // Khởi tạo EventChannel cho streamAllTasks
    val eventChannel = EventChannel(binding.binaryMessenger, "ditto_plugin/tasks")
    eventChannel.setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
          Log.d("DittoPlugin", "EventChannel onListen called")
          eventSink.add(events)
          startObservingTasks()
        }

        override fun onCancel(arguments: Any?) {
          Log.d("DittoPlugin", "EventChannel onCancel called")
          eventSink.forEach { it?.endOfStream() }
          eventSink.clear()
        }
      }
    )
  }

  override fun onMethodCall( call: MethodCall, result: Result) {
    Log.d("DittoPlugin", "onMethodCall called, method: ${call.method}")
    when (call.method) {
      "initializeDitto" -> initializeDitto(call, result)
      "save" -> save(call)
      "delete" -> delete(call, result)
      "getAllTasks" -> getAllTasks(result)
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

  private fun save(call: MethodCall) {
    Log.d("DittoPlugin", "save called")
    val documentId = call.argument<String>("documentId") ?: ""
    val body = call.argument<String>("body") ?: ""
    val isCompleted = call.argument<Boolean>("isCompleted") ?: false

    val doc = ditto.store["tasks"]
      .findById(DittoDocumentId(documentId))
      .exec()
    if (doc == null) {
      if (documentId == "") {
        ditto.store.collection("tasks")
          .upsert(
            mapOf(
              "body" to body,
              "isCompleted" to isCompleted,
              "isDeleted" to false
            )
          )
      } else {
        ditto.store.collection("tasks").findById(DittoDocumentId(documentId))
          .update { dittoDocument ->
            val mutableDoc = dittoDocument ?: return@update
            mutableDoc["body"].set(body)
            mutableDoc["isCompleted"].set(isCompleted)
          }
      }
    }
    Log.d("DittoPlugin", "Task saved: documentId: $documentId, body: $body, isCompleted: $isCompleted")
  }

  private fun delete(call: MethodCall, result: Result) {
    Log.d("DittoPlugin", "delete called")
    val documentId = call.argument<String>("documentId") ?: ""
    if (documentId.isBlank()) {
      result.error("ERROR", "Missing documentId", null)
      return
    }
    ditto.store.collection("tasks").findById(documentId).remove()
    Log.d("DittoPlugin", "Task deleted: documentId: $documentId")
  }

  private fun getAllTasks(result: Result) {
    Log.d("DittoPlugin", "getAllTasks called")
    val tasksCollection = ditto.store["tasks"]
    ditto.sync.registerSubscription("SELECT * FROM tasks")

    tasksCollection
      .find("!isDeleted")
      .sort("createdOn", DittoSortDirection.Ascending)
      .observeLocal { docs, _ ->
        Log.d("DittoPlugin", "getAllTasks observeLocal called, docs: $docs")
        val jsonString = docs.joinToString(separator = ",") { document ->
          document.value.toString()
        }
        result.success("[$jsonString]")
      }

  }

//  private fun streamAllTasks() {
//    Log.d("DittoPlugin", "streamAllTasks called")
//    val tasksCollection = ditto.store["tasks"]
//    ditto.sync.registerSubscription("SELECT * FROM tasks")
//
//    tasksCollection
//      .find("!isDeleted")
//      .sort("createdOn", DittoSortDirection.Ascending)
//      .observeLocal { docs, _ ->
//        try {
//          Log.d("DittoPlugin", "streamAllTasks observeLocal called, docs: $docs")
//          val jsonString = docs.joinToString(separator = ",") { document ->
//            document.value.toString()
//          }
//          eventSink.forEach { it?.success("[$jsonString]") }
//        } catch (e: Exception) {
//          Log.e("DittoPlugin", "Error in streamAllTasks observeLocal: ", e)
//          eventSink.forEach { it?.error("ERROR", e.message, null) }
//        }
//      }
//  }

  private fun startObservingTasks() {
    val tasksCollection = ditto.store["tasks"]
    ditto.sync.registerSubscription("SELECT * FROM tasks")

    tasksCollection
      .find("!isDeleted")
      .sort("createdOn", DittoSortDirection.Ascending)
      .observeLocal { docs, _ ->
        try {
          Log.d("DittoPlugin", "streamAllTasks observeLocal called, docs: $docs")
//          val gson = Gson()
//          val jsonString = gson.toJson(docs)
          val jsonString = StringBuilder().apply {
            docs.forEachIndexed { index, document ->
              append("{")
              append("\"id\": \"${document.id}\",")
              append("\"body\": \"${document.value["body"]}\",")
              append("\"isCompleted\": \"${document.value["isCompleted"]}\"")
              append("}")
              if (index < docs.size - 1) {
                append(",")
              }
            }
          }.toString()

          Handler(Looper.getMainLooper()).post {
            eventSink.forEach { it?.success("[$jsonString]") }
          }
        } catch (e: Exception) {
          Log.e("DittoPlugin", "Error in streamAllTasks observeLocal: ", e)
          eventSink.forEach { it?.error("ERROR", e.message, null) }
        }
      }
  }

}