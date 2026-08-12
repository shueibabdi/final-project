import 'package:flutter/foundation.dart';

import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [
    Todo(id: '1', title: 'Learn Flutter', isCompleted: true),
    Todo(id: '2', title: 'Learn Dart'),
  ];

  List<Todo> get todos => List.unmodifiable(_todos);

  void addTodo(String title) {
    _todos.add(
      Todo(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title),
    );
    notifyListeners();
  }

  void editTodo(String id, String title) {
    final todo = _findById(id);
    if (todo == null) return;
    todo.title = title;
    notifyListeners();
  }

  void toggleTodo(String id) {
    final todo = _findById(id);
    if (todo == null) return;
    todo.isCompleted = !todo.isCompleted;
    notifyListeners();
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  Todo? _findById(String id) {
    for (final todo in _todos) {
      if (todo.id == id) return todo;
    }
    return null;
  }
}
