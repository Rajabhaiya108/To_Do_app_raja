import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const ToDoHomePage(),
    );
  }
}

class Task {
  String title;
  String description;
  bool isCompleted;
  String emoji;

  Task({
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.emoji = '',
  });
}

class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key});

  @override
  State<ToDoHomePage> createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  final List<Task> _tasks = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final List<String> _emojis = ['😀', '👍', '❤', '🔥', '😎', '✔'];

  void _addTask() {
    if (_titleController.text.isEmpty) return;

    setState(() {
      _tasks.add(
        Task(title: _titleController.text, description: _descController.text),
      );
      _titleController.clear();
      _descController.clear();
    });
  }

  void _editTask(Task task, int index) {
    _titleController.text = task.title;
    _descController.text = task.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _tasks[index].title = _titleController.text;
                _tasks[index].description = _descController.text;
              });
              Navigator.pop(context);
              _titleController.clear();
              _descController.clear();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _toggleComplete(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  void _addEmojiToTask(int index, String emoji) {
    setState(() {
      _tasks[index].emoji = emoji;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My To-Do List")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
              ),
              onPressed: _addTask,
              child: const Text("Add Task"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(
                          task.isCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        onPressed: () => _toggleComplete(index),
                      ),
                      title: Text(
                        "${task.title} ${task.emoji}",
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(task.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.emoji_emotions_outlined),
                            onSelected: (emoji) =>
                                _addEmojiToTask(index, emoji),
                            itemBuilder: (context) => _emojis
                                .map(
                                  (emoji) => PopupMenuItem(
                                    value: emoji,
                                    child: Text(emoji),
                                  ),
                                )
                                .toList(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => _copyToClipboard(
                              "${task.title} - ${task.description}",
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTask(task, index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
