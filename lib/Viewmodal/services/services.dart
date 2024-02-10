// services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Model/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTask(Task task) async {
    await _firestore.collection('tasks').add({
      'title': task.title,
      'description': task.description,
    });
  }

  Stream<List<Task>> getTasks() {
    return _firestore
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Task(
                id: doc.id,
                title: doc['title'],
                description: doc['description'],
              );
            }).toList());
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'title': task.title,
      'description': task.description,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}
