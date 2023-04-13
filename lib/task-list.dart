import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';
import 'package:flutter/material.dart';
class TaskListPage extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}
class _TasksScreenState extends State<TaskListPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('tasks').orderBy('finished').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Center (child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          final List<Task> tasks = documents.map((doc) => Task(
            doc.id,
            doc['name'],
            priority: doc['priority'],
            finished: doc['finished'],
            // selectedPriority: null,
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
