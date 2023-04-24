import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_list/login.dart';
import 'main.dart';
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

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Query tasksQuery =
        _db.collection('tasks').where('userId', isEqualTo: user?.uid).orderBy('priority').orderBy('name');

    if (showFinishedTasks == false) {
      tasksQuery = tasksQuery.where('finished', isEqualTo: false);
    }

    return Scaffold(
      backgroundColor: Color(0xFFD1C4E9),
      appBar: AppBar(
        title: Text("Tarefas", style: TextStyle(fontSize: 24.0, color: Colors.white),),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: 
              Row(
                children: [
                  IconButton(
                    icon: isButtonPressed ? Icon(Icons.task_outlined) :  Icon(Icons.task_sharp),
                    onPressed: () {
                      setState(() {
                        showFinishedTasks = !showFinishedTasks;
                        isButtonPressed = !isButtonPressed;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      runApp(MyApp());
                    },
                  )
                ],
              ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tasksQuery.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // return Text('Erro: ${snapshot.error}');
            print(snapshot.error);
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


          return Container(
            margin: EdgeInsets.only(top: 30.0),
            child: ListView(
              children: tasks.map((task) {
                return Dismissible(
                  key: Key(task.id!),
                  confirmDismiss: (direction) {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Color(0xFFD1C4E9),
                          title: Text('Apagar tarefa'),
                          content: Text('Deseja realmente apagar a tarefa?'),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                // Navigator.pop(context, false);
                                Navigator.of(
                                  context,
                                  // rootNavigator: true,
                                ).pop(false);
                              },
                              child: Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Navigator.pop(context, true);
                                Navigator.of(
                                  context,
                                  // rootNavigator: true,
                                ).pop(true);
                              },
                              child: Text('Apagar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (_) async {
                    await _db.collection('tasks').doc(task.id).delete();
                  },
                  child: CheckboxListTile(
                    title: Text(
                      task.name!,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                    value: task.finished!,
                    // onChanged: null,
                    onChanged: (bool? value) async {
                      setState(() {
                        task.finished = value!;
                      });
                      await updateTaskField(task.id!, 'finished', task.finished);
                    },
                    subtitle: DropdownButtonFormField<String>(
                      dropdownColor: Color(0xFFD1C4E9),
                      icon: Icon(
                        Icons.arrow_drop_down, 
                        color: Color(0xFFE040FB),
                      ),
                      value: '${task.priority}_${task.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF212121),
                      ),
                      items: [
                        DropdownMenuItem(value: 'low_${task.id}', child: Text('Prioridade Baixa')),
                        DropdownMenuItem(value: 'medium_${task.id}', child: Text('Prioridade Média')),
                        DropdownMenuItem(value: 'high_${task.id}', child: Text('Prioridade Alta')),
                      ],
                      onChanged: (String? value) async {
                        setState(() {
                          task.priority = value!;
                        });
                        String? priority = task.priority?.split('_')[0];
                        await updateTaskField(task.id!, 'priority', priority);
                      },
                      decoration: InputDecoration(
                        hintText: 'Prioridade',
                      ),
                    ),
                    // subtitle: Text(task.priority!),
                    // value: task.finished!,
                    // onChanged: (bool? value) async {
                    //   setState(() {
                    //     task.finished = value!;
                    //   });
                    //   await updateTaskField(task.id!, 'finished', task.finished);
                    // },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/task-create'),
        child: Icon(Icons.add),
      ),
    );
    
  }
  Widget buildTasksList(Query tasksQuery) {
    return StreamBuilder<QuerySnapshot>(
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
        final List<Task> tasks = documents
            .map((doc) => Task(
                  doc.id,
                  doc['name'],
                  priority: doc['priority'],
                  finished: doc['finished'],
                ))
            .toList();

        return ListView(
          children: tasks.map((task) {
            return Dismissible(
              key: Key(task.id!),
              onDismissed: (_) async {
                await _db.collection('tasks').doc(task.id).delete();
              },
              child: CheckboxListTile(
                title: Text(task.name!),
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