import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Model/user_model.dart';

class TodoController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxList<Todo> todos = <Todo>[].obs;
  File? imageFile;

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
      String imageUrl = await uploadImage();
      await FirebaseFirestore.instance.collection('todos').doc(todoId).update({
        'title': titleController.text,
        'description': descriptionController.text,
        'imageUrl': imageUrl,
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
      String imageUrl = await uploadImage();
      await FirebaseFirestore.instance.collection('todos').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'imageUrl': imageUrl,
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

  Future<String> uploadImage() async {
    try {
      if (imageFile != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('todo_images/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putFile(imageFile!);
        await uploadTask.whenComplete(() => null);
        return await storageReference.getDownloadURL();
      } else {
        return ''; // or any default image URL if no image is selected
      }
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // handle error case
    }
  }

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      update(); // update the state to reflect the change in the UI
    } else {
      print('No image selected.');
    }
  }
}
