import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskCreatePage extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TaskCreatePage> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Task"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nome'
                )
            ),
            DropdownButtonFormField<String>(
              value: 'low',
              items: [
                DropdownMenuItem(value: 'low', child: Text('Baixa')),
                DropdownMenuItem(value: 'medium', child: Text('Média')),
                DropdownMenuItem(value: 'high', child: Text('Alta')),
              ],
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: 'Prioridade',
              ),
            ),
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                        final name = _nameController.text.trim();
                        if (name.isNotEmpty) {
                          await _db.collection('tasks').add({
                            'name': name,
                            'priority': 'low',
                            'finished': false,
                          });
                          _nameController.clear();
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Salvar'),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
