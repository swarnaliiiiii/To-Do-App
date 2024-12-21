import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

Future<void> saveTaskToFirestore({
  required String title,
  required String description,
  required DateTime dueDate,
  required String dueTime,
  required String priority,
  required String taskid,
}) async {
  try {
    // Reference to Firestore
    CollectionReference task = FirebaseFirestore.instance.collection('task');

    // Save the task
    await task.add({
      'taskid': taskid,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'dueTime': dueTime,
      'priority': priority,
      'createdAt': Timestamp.now(),
    });

    print('Task saved successfully!');
  } catch (e) {
    print('Failed to save task: $e');
  }
}
