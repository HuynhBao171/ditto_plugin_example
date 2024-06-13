import 'dart:async';
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
  }

  @override
  void dispose() {
    super.dispose();
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
                  logger.i('Task saved in HomePage');
                },
                onDelete: (taskId) async {
                  await _dittoPlugin.delete(taskId);
                  logger.i('Task deleted in HomePage');
                },
              ),
            ),
          );
        },
        label: const Row(
          children: <Widget>[
            Icon(Icons.add),
            SizedBox(width: 2),
            Text("Add new task"),
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
      body: StreamBuilder<List<dynamic>>(
        stream: _dittoPlugin.streamAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final fetchedTasks = snapshot.data!;
            tasks = fetchedTasks.map((taskData) {
              final isCompleted = taskData['isCompleted'] == 'true';
              return Task.fromJson({
                ...taskData,
                'isCompleted': isCompleted,
              });
            }).toList();

            return ListView.builder(
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
                            await _dittoPlugin.save(
                              documentId: updatedTask.id,
                              body: updatedTask.body,
                              isCompleted: updatedTask.isCompleted,
                            );
                            logger.i('Task saved in HomePage');
                          },
                          onDelete: (taskId) async {
                            await _dittoPlugin.delete(taskId);
                            logger.i('Task deleted in HomePage');
                          },
                        ),
                      ),
                    );
                  },
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          task.isCompleted = value;
                        });
                        // try {
                        //   await _dittoPlugin.save(
                        //     documentId: task.id,
                        //     body: task.body,
                        //     isCompleted: value,
                        //   );
                        // } catch (e) {
                        //   logger.e("Error saving task: $e");

                        //   setState(() {
                        //     task.isCompleted = !value;
                        //   });

                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(content: Text("Error saving task")),
                        //   );
                        // }
                      }
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
            );
          } else if (snapshot.hasError) {
            logger.e("Error listening to tasks: ${snapshot.error}");
            return const Center(child: Text("Error loading tasks"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
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
