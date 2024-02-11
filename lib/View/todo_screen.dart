import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/Viewmodal/services/services.dart';

import '../Model/user_model.dart';

class YourTodoScreen extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Todo App'),
      ),
      body: Column(
        children: [
          TextField(
            controller: todoController.titleController,
            decoration: InputDecoration(
              labelText: 'Title',
            ),
          ),
          TextField(
            controller: todoController.descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
          ),
          ElevatedButton(
            onPressed: () => todoController.getImage(),
            child: Text('Pick Image'),
          ),
          CircleAvatar(
            child: todoController.imageFile != null
                ? Image.file(todoController.imageFile!)
                : CircleAvatar(
                    child: Icon(Icons.image),
                  ),
          ),
          ElevatedButton(
            onPressed: () => todoController.addTodo(),
            child: Text('Add Todo'),
          ),
          Expanded(
            child: Obx(() {
              if (todoController.todos.isEmpty) {
                return Center(child: Text('No todos yet.'));
              } else {
                return ListView.builder(
                  itemCount: todoController.todos.length,
                  itemBuilder: (context, index) {
                    Todo todo = todoController.todos[index];
                    return ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.description),
                      leading: todo.imageUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(todo.imageUrl!),
                            )
                          : CircleAvatar(
                              child: Icon(Icons.image),
                            ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => todoController.deleteTodo(todo.id),
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Update Todo'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: todoController.titleController,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                ),
                                onChanged: (value) =>
                                    todoController.titleController.text = value,
                              ),
                              TextField(
                                controller:
                                    todoController.descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                ),
                                onChanged: (value) => todoController
                                    .descriptionController.text = value,
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    todoController.updateTodo(todo.id),
                                child: Text('Update Todo'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
