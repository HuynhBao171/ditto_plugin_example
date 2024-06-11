import 'dart:convert';

import 'package:ditto_plugin/ditto_plugin.dart';
import 'package:ditto_plugin_example/model/task.dart';
import 'package:ditto_plugin_example/presentation/edit_task.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  final _dittoPlugin = DittoPlugin();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // Future<void> _fetchTasks() async {
  //   try {
  //     final fetchedTasks = await _dittoPlugin.getAllTasks();
  //     final mappedTasks =
  //         fetchedTasks.map((taskData) => Task.fromJson(taskData)).toList();
  //     setState(() {
  //       tasks = mappedTasks;
  //     });
  //     logger.i("Tasks fetched successfully: ${tasks.length} tasks.");
  //   } catch (e) {
  //     logger.i("Error fetching tasks: $e");
  //   }
  // }

  Future<void> _fetchTasks() async {
    try {
      final fetchedTasks = await _dittoPlugin.getAllTasks();

      final mappedTasks = fetchedTasks.map((taskData) {
        // Chuyển đổi "true"/"false" thành bool
        final isCompleted = taskData['isCompleted'] == 'true';

        return Task.fromJson({
          ...taskData,
          'isCompleted': isCompleted,
        });
      }).toList();

      setState(() {
        tasks = mappedTasks;
      });
      logger.i("Tasks fetched successfully: ${tasks.length} tasks.");
    } catch (e) {
      logger.i("Error fetching tasks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(
                task: Task(id: '', body: '', isCompleted: false),
                onSave: (updatedTask) async {
                  await _dittoPlugin.save(
                    documentId: updatedTask.id,
                    body: updatedTask.body,
                    isCompleted: updatedTask.isCompleted,
                  );
                  _fetchTasks();
                },
                onDelete: (taskId) async {
                  await _dittoPlugin.delete(taskId);
                  _fetchTasks();
                },
              ),
            ),
          );
        },
        label: const Row(
          children: <Widget>[
            Icon(Icons.add), // Icon
            SizedBox(width: 2), // Space between icon and text
            Text("Add new task"), // Text
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Ditto Tasks'),
        actions: [
          IconButton(
            onPressed: _showDittoSettingsModal,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskScreen(
                    task: task,
                    onSave: (updatedTask) async {
                      try {
                        await _dittoPlugin.save(
                          documentId: updatedTask.id,
                          body: updatedTask.body,
                          isCompleted: updatedTask.isCompleted,
                        );
                        logger.i('Task saved in HomePage');
                      } catch (e) {
                        logger.i('Error saving task in HomePage: $e');
                      }
                      // await _dittoPlugin.save(
                      //   documentId: updatedTask.id,
                      //   body: updatedTask.body,
                      //   isCompleted: updatedTask.isCompleted,
                      // );
                      // logger.i('Task saved in HomePage');
                    },
                    onDelete: (taskId) async {
                      await _dittoPlugin.delete(taskId);
                      logger.i('Task deleted in HomePage');
                    },
                  ),
                ),
              ).then((_) => _fetchTasks());
            },
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                setState(() {
                  task.isCompleted = value!;
                });
              },
            ),
            title: Text(
              task.body,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          );
        },
      ),
    );
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
