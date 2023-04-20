import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_list/task-create.dart';
import 'package:task_list/task-list.dart';
import 'firebase_options.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Erro ao inicializar o Firebase"),
            );
          }
    
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
    
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/task-list',
            routes: {
              '/task-create': (context) => TaskCreatePage(),
              '/task-list': (context) => TaskListPage()
            },
          );
        },
      ),
    );
  }
}

Future<FirebaseApp?> _initializeFirebase() async {
  try {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return app;
  } catch (e) {
    print('Error initializing Firebase: $e');
    return null;
  }
}
