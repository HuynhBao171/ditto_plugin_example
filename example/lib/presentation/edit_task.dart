import 'package:ditto_plugin_example/model/task.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class EditTaskScreen extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;
  final Function(String) onDelete;

  const EditTaskScreen({
    super.key,
    this.task,
    required this.onSave,
    required this.onDelete,
  });

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _bodyController;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: widget.task?.body ?? '');
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task?.id != '' ? 'Edit Task' : 'Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
            CheckboxListTile(
              title: const Text('Completed'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value!;
                  logger.i('Completed: $_isCompleted');
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onSave(
                  Task(
                    id: widget.task?.id,
                    body: _bodyController.text,
                    isCompleted: _isCompleted,
                  ),
                );
                logger.i('Task saved');
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16),
            if (widget.task!.id != '')
              ElevatedButton(
                onPressed: () {
                  widget.onDelete(widget.task!.id!);
                  logger.i('Task deleted');
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.black)),
              ),
          ],
        ),
      ),
    );
  }
}
