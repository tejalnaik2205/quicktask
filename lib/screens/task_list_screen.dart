import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/back4app_service.dart';
import 'package:tms/widgets/task_tile.dart';
import 'login_screen.dart'; // Import your login screen for navigation

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final fetchedTasks = await Back4AppService().fetchTasks();
      setState(() {
        tasks = fetchedTasks.map((e) => Task.fromParseObject(e)).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching tasks: ${error.toString()}")),
      );
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
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
                final dueDate = DateTime.parse(dueDateController.text); // Ensure this is a valid DateTime

                try {
                  await Back4AppService().createTask(title, dueDate);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Task added successfully")),
                  );
                  _fetchTasks(); // To refresh the task list
                  Navigator.pop(context); // Close the dialog automatically after adding
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error adding task: ${error.toString()}")),
                  );
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await Back4AppService().logout();
      // Redirect to the LoginScreen after successful logout
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: ${error.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,  // Trigger logout when tapped
            tooltip: 'Logout',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks found. Add a new task!"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskTile(
                  task: task,
                  onTaskUpdated: _fetchTasks,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
