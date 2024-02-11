import 'dart:io';

class Todo {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final File? localImageFile; // Add localImageFile attribute

  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.localImageFile, // Add this line
  });

  factory Todo.fromMap(String id, Map<String, dynamic> map) {
    return Todo(
      id: id,
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      localImageFile: map['localImageFile'], // Assign localImageFile from map
    );
  }
}
