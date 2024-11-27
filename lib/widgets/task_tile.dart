import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import DateFormat here
import '../models/task.dart';
import '../services/back4app_service.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function onTaskUpdated;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text("Due: ${task.dueDate.toLocal()}"),  // Show date in local time zone
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkbox to mark task completion
          Checkbox(
            value: task.isCompleted,
            onChanged: (value) async {
              await _toggleTaskCompletion(value ?? false, context);
            },
          ),
          // Delete button
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTask(context),
          ),
        ],
      ),
      onTap: () => _showEditTaskDialog(context), // Trigger the edit task dialog
    );
  }

  Future<void> _toggleTaskCompletion(bool isCompleted, BuildContext context) async {
    try {
      await Back4AppService().updateTask(task.objectId, isCompleted: isCompleted);
      onTaskUpdated(); // Refresh the UI after successful update
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating task: ${error.toString()}")),
      );
    }
  }

  Future<void> _deleteTask(BuildContext context) async {
    try {
      await Back4AppService().deleteTask(task.objectId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task deleted successfully")),
      );
      onTaskUpdated(); // Refresh the task list after deletion
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting task: ${error.toString()}")),
      );
    }
  }

  void _showEditTaskDialog(BuildContext context) {
    final titleController = TextEditingController(text: task.title);

    // Convert UTC to local date before showing it in the dialog
    final localDueDate = task.dueDate.toLocal();
    final dueDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(localDueDate));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date (yyyy-MM-dd)'),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text;
                final dateString = dueDateController.text;
                final DateFormat format = DateFormat('yyyy-MM-dd'); // Ensure this matches the input format

                try {
                  final DateTime dueDate = format.parseStrict(dateString); // Strict parse to handle invalid formats

                  // Update the task
                  await Back4AppService().updateTask(task.objectId, title: title, dueDate: dueDate);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Task updated successfully")),
                    );

                    onTaskUpdated(); // Refresh the task list
                    Navigator.pop(context); // Close the dialog if the widget is still mounted
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error updating task: Invalid date format")),
                    );
                  }
                }
              },
              child: const Text('Update Task'),
            ),
          ],
        );
      },
    );
  }
}
