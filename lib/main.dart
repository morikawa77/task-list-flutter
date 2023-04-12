import 'package:flutter/material.dart';
import 'package:task_list/task-create.dart';
import 'package:task_list/task-list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: TaskListPage(),
      initialRoute: '/task-list',
      routes: {
        '/task-create': (context) => TaskCreatePage(),
        '/task-list': (context) => TaskListPage()
      },
    );
  }
}
