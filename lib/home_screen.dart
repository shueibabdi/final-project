import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/todo.dart';
import 'providers/todo_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color(0xff0F172A),
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'My ',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'To Do',
                style: TextStyle(
                  color: Color(0xff22C55E),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.filter_alt_outlined,
              color: Color(0xff22C55E),
              size: 35,
            ),
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Tasks',
                      style: TextStyle(
                        color: Color(0xff111827),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.todos.length} Tasks',
                      style: const TextStyle(
                        color: Color(0xff22C55E),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: provider.todos.isEmpty
                      ? const Center(
                          child: Text(
                            'No tasks yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.todos.length,
                          itemBuilder: (context, index) =>
                              TaskCard(todo: provider.todos[index]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff22C55E),
        onPressed: () => showTodoSheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TodoProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(blurRadius: 18, color: Colors.grey.withOpacity(.12)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        leading: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => provider.toggleTodo(todo.id),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: todo.isCompleted
                  ? const Color(0xff22C55E)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xff22C55E), width: 3),
            ),
            child: todo.isCompleted
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            color: todo.isCompleted ? Colors.grey : const Color(0xff111827),
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            fontSize: 18,
          ),
        ),
        onTap: () => showTodoSheet(context, todo: todo),
        trailing: IconButton(
          tooltip: 'Delete task',
          icon: const Icon(
            Icons.delete_outline,
            color: Color(0xff22C55E),
            size: 30,
          ),
          onPressed: () => provider.deleteTodo(todo.id),
        ),
      ),
    );
  }
}

Future<void> showTodoSheet(BuildContext context, {Todo? todo}) async {
  final controller = TextEditingController(text: todo?.title ?? '');
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo == null ? 'Add task' : 'Edit task',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a task title'
                    : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final title = controller.text.trim();
                    final provider = context.read<TodoProvider>();
                    if (todo == null) {
                      provider.addTodo(title);
                    } else {
                      provider.editTodo(todo.id, title);
                    }
                    Navigator.pop(sheetContext);
                  },
                  child: Text(todo == null ? 'Add task' : 'Save changes'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  controller.dispose();
}
