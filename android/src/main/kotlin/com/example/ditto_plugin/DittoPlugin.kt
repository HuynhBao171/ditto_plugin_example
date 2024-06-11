package com.example.ditto_plugin

import com.example.ditto_plugin.data.Task
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import live.ditto.*
import live.ditto.android.DefaultAndroidDittoDependencies

/** DittoPlugin */
class DittoPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var ditto: Ditto
  private lateinit var binding: FlutterPlugin.FlutterPluginBinding

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ditto_plugin")
    channel.setMethodCallHandler(this)
    binding = flutterPluginBinding
  }

  override fun onMethodCall( call: MethodCall, result: Result) {
    when (call.method) {
      "initializeDitto" -> initializeDitto(call, result)
      "save" -> save(call)
      "delete" -> delete(call, result)
      "getAllTasks" -> getAllTasks(result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun initializeDitto(call: MethodCall, result: Result) {
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

    result.success(true)
  }

  private fun save(call: MethodCall) {
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
  }

  private fun delete(call: MethodCall, result: Result) {
    val documentId = call.argument<String>("documentId") ?: ""
    if (documentId.isBlank()) {
      result.error("ERROR", "Missing documentId", null)
      return
    }
    ditto.store.collection("tasks").findById(documentId).remove()
  }

  private fun getAllTasks(result: Result) {
    val tasksCollection = ditto.store["tasks"]

    var hasReplied = false

    tasksCollection
      .find("!isDeleted")
      .sort("createdOn", DittoSortDirection.Ascending)
      .observeLocal { docs, _ ->
        if (!hasReplied) {
          val jsonString = docs.joinToString(separator = ",") { document ->
            document.value.toString()
          }
          result.success("[$jsonString]")
          hasReplied = true // Đánh dấu đã gửi phản hồi
        }
      }
  }

}