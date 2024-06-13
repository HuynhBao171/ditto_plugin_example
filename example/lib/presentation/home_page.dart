import 'dart:async';
import 'dart:io';

import 'package:ditto_plugin/ditto_plugin.dart';
import 'package:ditto_plugin_example/model/message.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dittoPlugin = DittoPlugin();
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ditto Chat'),
        actions: [
          IconButton(
            onPressed: _showDittoSettingsModal,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getDeviceName(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final deviceName = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<dynamic>>(
                    stream: _dittoPlugin.streamAllMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final fetchedMessages = snapshot.data!;
                        _messages.clear();
                        _messages.addAll(fetchedMessages.map((messageData) {
                          final createdAt = messageData['createdAt'];
                          return Message.fromJson({
                            ...messageData,
                            'createdAt': createdAt,
                          });
                        }).toList());

                        return ListView.builder(
                          reverse: true,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                _messages[_messages.length - index - 1];
                            return _buildMessageBubble(message, deviceName);
                          },
                        );
                      } else if (snapshot.hasError) {
                        logger.e(
                            "Error listening to messages: ${snapshot.error}");
                        return const Center(
                            child: Text("Error loading messages"));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                _buildMessageInput(deviceName),
              ],
            );
          } else if (snapshot.hasError) {
            logger.e("Error getting device name: ${snapshot.error}");
            return const Center(child: Text("Error getting device name"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildMessageBubble(Message message, String deviceName) {
    final isMe = message.senderName == deviceName;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.createdAt,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(String deviceName) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(hintText: 'Enter message'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final content = _messageController.text.trim();
              if (content.isNotEmpty) {
                _sendMessage(content, deviceName);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String> _getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Unknown Device';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
      }
      logger.i('Device name obtained: $deviceName');
    } catch (e) {
      logger.e('Error getting device name: $e');
    }
    return deviceName;
  }

  Future<void> _sendMessage(String content, String deviceName) async {
    final message = Message(
      id: '',
      content: content,
      createdAt: DateFormat('HH:mm').format(DateTime.now()),
      senderName: deviceName,
    );
    try {
      await _dittoPlugin.sendMessage(
        messageId: message.id,
        content: message.content,
        createdAt: message.createdAt,
        senderName: message.senderName,
      );
    } catch (e) {
      logger.e('Failed to send message: $e');
    }
  }

  void _showDittoSettingsModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ditto Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: appId,
                decoration: const InputDecoration(labelText: 'App ID'),
                onChanged: (value) {
                  appId = value;
                  logger.i("App ID changed: $appId");
                },
              ),
              TextFormField(
                initialValue: token,
                decoration: const InputDecoration(labelText: 'Token'),
                onChanged: (value) {
                  token = value;
                  logger.i("Token changed: $token");
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _dittoPlugin.initializeDitto(appId, token);
                  Navigator.pop(context);
                  logger.i(
                      "Ditto initialized with App ID: $appId and Token: $token");
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
