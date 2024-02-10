import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Firebase CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxList<Todo> todos = <Todo>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    try {
      var result = await FirebaseFirestore.instance.collection('todos').get();
      todos.assignAll(result.docs
          .map(
              (doc) => Todo.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList());
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }

  Future<void> updateTodo(String todoId) async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(todoId).update({
        'title': titleController.text,
        'description': descriptionController.text,
      });
      titleController.clear();
      descriptionController.clear();
      fetchTodos();
    } catch (e) {
      print('Error updating todo: $e');
    }
  }

  Future<void> addTodo() async {
    try {
      await FirebaseFirestore.instance.collection('todos').add({
        'title': titleController.text,
        'description': descriptionController.text,
      });
      titleController.clear();
      descriptionController.clear();
      fetchTodos();
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await FirebaseFirestore.instance.collection('todos').doc(todoId).delete();
      fetchTodos();
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }
}

class TodoListScreen extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: todoController.titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: todoController.descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ),
          ElevatedButton(
            onPressed: todoController.addTodo,
            child: Text('Add Todo'),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: todoController.todos.length,
                itemBuilder: (context, index) {
                  final todo = todoController.todos[index];
                  return ListTile(
                    title: Text(todo.title),
                    subtitle: Text(todo.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => todoController.deleteTodo(todo.id),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditDialog(context, todo),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Todo todo) async {
    todoController.titleController.text = todo.title;
    todoController.descriptionController.text = todo.description;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: todoController.titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: todoController.descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                todoController.updateTodo(todo.id);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

class Todo {
  final String id;
  final String title;
  final String description;

  Todo({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> map) {
    return Todo(
      id: id,
      title: map['title'],
      description: map['description'],
    );
  }
}
