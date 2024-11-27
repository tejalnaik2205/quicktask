import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Back4AppService {
  // Initialize Parse SDK
  static Future<void> initialize() async {
    await Parse().initialize(
      'yxkhf4cTvwO886JxArxS3eqBueZK52bwgk7gMO8c', // Application ID
      'https://parseapi.back4app.com',           // Server URL
      clientKey: 'krPrpqsEC6cLb6FeZ754vI9GPp2se2Y2AtpfSvfC', // Client Key
      autoSendSessionId: true,
    );
  }

  // Sign Up a New User
  Future<ParseUser?> signUp(String username, String password) async {
    final user = ParseUser(username, password, username); // Email used as username
    final response = await user.signUp();

    if (response.success) {
      return user;
    } else {
      throw Exception(response.error?.message ?? 'Sign-up failed');
    }
  }

  // Log In an Existing User
  Future<ParseUser?> login(String username, String password) async {
    final user = ParseUser(username, password, null);
    final response = await user.login();

    if (response.success) {
      return user;
    } else {
      throw Exception(response.error?.message ?? 'Login failed');
    }
  }

  // Log Out the Current User
  Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    final response = await user?.logout();

    if (!response!.success) {
      throw Exception(response.error?.message ?? 'Logout failed');
    }
  }

  // Create a New To-Do Task
  Future<void> createTask(String title, DateTime dueDate) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) {
      throw Exception("No user logged in");
    }
  
    final task = ParseObject('Task')
      ..set('title', title)
      ..set('dueDate', dueDate)
      ..set('isCompleted', false)
      ..set('createdBy', currentUser.objectId); // Associate task with the user
  
    final response = await task.save();
  
    if (!response.success) {
      throw Exception(response.error?.message ?? 'Task creation failed');
    }
  }

  // Retrieve All To-Do Tasks
  Future<List<ParseObject>> fetchTasks() async {
    try {
      // Create the query for tasks
      final query = QueryBuilder<ParseObject>(ParseObject('Task'));
  
      // Optionally, filter tasks by user if the 'createdBy' field exists
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser != null) {
        query.whereEqualTo('createdBy', currentUser.objectId);
      }
  
      final response = await query.query();
  
      // Log response for debugging
      if (response.success) {
        print("Fetch successful: ${response.results?.length ?? 0} tasks found.");
        return response.results as List<ParseObject>? ?? [];
      } else {
        print("Fetch error: ${response.error?.message}");
        throw Exception(response.error?.message ?? 'Failed to fetch tasks');
      }
    } catch (error) {
      print("Fetch exception: $error");
      throw Exception("Error fetching tasks: $error");
    }
  }
  
    // Update a Task (Mark as Completed or Update Details)
  Future<void> updateTask(String objectId, {String? title, DateTime? dueDate, bool? isCompleted}) async {
    final task = ParseObject('Task')..objectId = objectId;

    if (title != null) task.set('title', title);
    if (dueDate != null) task.set('dueDate', dueDate);
    if (isCompleted != null) task.set('isCompleted', isCompleted);

    final response = await task.save();

    if (!response.success) {
      throw Exception(response.error?.message ?? 'Task update failed');
    }
  }

  // Delete a Task
  Future<void> deleteTask(String objectId) async {
    final task = ParseObject('Task')..objectId = objectId;
    final response = await task.delete();

    if (!response.success) {
      throw Exception(response.error?.message ?? 'Task deletion failed');
    }
  }
}
