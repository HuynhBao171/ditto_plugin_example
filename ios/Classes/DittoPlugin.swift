import Flutter
import UIKit
import DittoSwift
import Combine

public class DittoPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var ditto: Ditto?
    var cancellables = Set<AnyCancellable>()
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "ditto_plugin", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "ditto_plugin/chat", binaryMessenger: registrar.messenger())
        let instance = DittoPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeDitto":
            initializeDitto(call: call, result: result)
        case "sendMessage":
            sendMessage(call: call, result: result)
        case "deleteMessage":
            deleteMessage(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startStreamingTasks()
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    private func startStreamingTasks() {
        guard let ditto = self.ditto else {
            return
        }

        let query = ditto.store["chat"].find("!isDeleted")

        query.liveQueryPublisher()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    self.eventSink?(FlutterError(code: "DITTO_ERROR", message: "Error fetching tasks", details: error.localizedDescription))
                }
            }, receiveValue: { docs, _ in
                let tasks = docs.compactMap { doc -> [String: Any]? in
                    guard let dict = doc.value as? [String: Any] else { return nil }
                    return dict
                }
                do {
                    let data = try JSONSerialization.data(withJSONObject: tasks, options: [])
                    if let jsonString = String(data: data, encoding: .utf8) {
                        self.eventSink?(jsonString)
                    } else {
                        self.eventSink?(FlutterError(code: "JSON_ENCODING_ERROR", message: "Failed to encode JSON string", details: nil))
                    }
                } catch {
                    self.eventSink?(FlutterError(code: "JSON_SERIALIZATION_ERROR", message: "Failed to serialize tasks to JSON", details: error.localizedDescription))
                }
            })
            .store(in: &self.cancellables)
    }

    private func initializeDitto(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: String],
              let appId = arguments["appId"],
              let token = arguments["token"] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid appId or token provided", details: nil))
            return
        }

        self.ditto = Ditto(
            identity: .onlinePlayground(
                appID: appId,
                token: token
            )
        )

        do {
            try self.ditto?.startSync()
            result(nil)
        } catch {
            result(FlutterError(code: "SYNC_ERROR", message: "Failed to start sync", details: error.localizedDescription))
        }
    }

    private func sendMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let ditto = self.ditto else {
          result(FlutterError(code: "DITTO_NOT_INITIALIZED", message: "Ditto is not initialized", details: nil))
          return
      }

      guard let arguments = call.arguments as? [String: Any],
            let messageId = arguments["messageId"] as? String?,
            let content = arguments["content"] as? String,
            let createdAt = arguments["createdAt"] as? String,
            let senderName = arguments["senderName"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
          return
      }

      print("MessageId: \(messageId ?? "nil"), Content: \(content), CreatedAt: \(createdAt), SenderName: \(senderName)")

      do {
          var message: [String: Any] = [
              "id": messageId,
              "content": content,
              "createdAt": createdAt,
              "senderName": senderName,
              "isDeleted" : false
          ]
          
          try ditto.store["chat"].upsert(message)
          result(nil)
      } catch {
          result(FlutterError(code: "DITTO_ERROR", message: "Error sending message", details: error.localizedDescription))
      }
    }

    private func deleteMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let ditto = self.ditto else {
            result(FlutterError(code: "DITTO_NOT_INITIALIZED", message: "Ditto is not initialized", details: nil))
            return
        }

        guard let arguments = call.arguments as? [String: String],
              let documentId = arguments["messageId"] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid documentId provided", details: nil))
            return
        }

        do {
            try ditto.store["chat"].findByID(documentId).update { mutableDoc in
                mutableDoc?["isDeleted"].set(true)
            }
            result(nil)
        } catch {
            result(FlutterError(code: "DITTO_ERROR", message: "Error deleting task", details: error.localizedDescription))
        }
    }
}
