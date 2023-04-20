import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';
import 'package:flutter/material.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TaskListPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool showFinishedTasks = true;
  bool isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    Query tasksQuery =
        _db.collection('tasks').orderBy('priority').orderBy('name');

    if (showFinishedTasks == false) {
      tasksQuery = tasksQuery.where('finished', isEqualTo: false);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: IconButton(
              icon: isButtonPressed ? Icon(Icons.task_outlined) :  Icon(Icons.task_sharp),
              onPressed: () {
                setState(() {
                  showFinishedTasks = !showFinishedTasks;
                  isButtonPressed = !isButtonPressed;
                });
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tasksQuery.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
            // print(snapshot.error);
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          final List<Task> tasks = documents.map((doc) => Task(
                doc.id,
                doc['name'],
                priority: doc['priority'],
                finished: doc['finished'],
              )).toList();

          return ListView(
            children: tasks.map((task) {
              return Dismissible(
                key: Key(task.id!),
                onDismissed: (_) async {
                  await _db.collection('tasks').doc(task.id).delete();
                },
                child: CheckboxListTile(
                  title: Text(task.name!),
                  // subtitle: DropdownButtonFormField<String>(
                  //   value: '${task.priority}_${task.id}',
                  //   items: [
                  //     DropdownMenuItem(value: 'low_${task.id}', child: Text('Prioridade Baixa')),
                  //     DropdownMenuItem(value: 'medium_${task.id}', child: Text('Prioridade Média')),
                  //     DropdownMenuItem(value: 'high_${task.id}', child: Text('Prioridade Alta')),
                  //   ],
                  //   onChanged: (String? value) async {
                  //     setState(() {
                  //       task.selectedPriority = value!;
                  //     });
                  //     String? priority = task.selectedPriority?.split('_')[0];
                  //     await updateTaskField(task.id!, 'priority', priority);
                  //   },
                  //   decoration: InputDecoration(
                  //     hintText: 'Prioridade',
                  //   ),
                  // ),
                  subtitle: Text(task.priority!),
                  value: task.finished!,
                  onChanged: (bool? value) async {
                    setState(() {
                      task.finished = value!;
                    });
                    await updateTaskField(task.id!, 'finished', task.finished);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/task-create'),
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<void> updateTaskField(String taskId, String field, dynamic newValue) async {
  try {
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(taskId)
        .update({field: newValue});
  } catch (e) {
    print('Erro ao atualizar a tarefa: $e');
  }
}