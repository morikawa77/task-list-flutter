import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_list/task-list.dart';

class TaskCreatePage extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TaskCreatePage> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _selectedPriority = 'low';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1C4E9),
      appBar: AppBar(
        title: Text("Adicionar nova tarefa", style: TextStyle(fontSize: 24.0, color: Colors.white),),
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
              dropdownColor: Color(0xFFD1C4E9),
              value: _selectedPriority,
              style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
              items: [
                DropdownMenuItem(value: 'low', child: Text('Prioridade Baixa')),
                DropdownMenuItem(value: 'medium', child: Text('Prioridade Média')),
                DropdownMenuItem(value: 'high', child: Text('Prioridade Alta')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!; 
                });
              },
              decoration: InputDecoration(
                hintText: 'Prioridade',
              ),
            ),
            Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TaskListPage()));
                          },
                          child: Text('Cancelar'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, 
                            backgroundColor: Color(0xFFE040FB),
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onPressed: () async {
                              final name = _nameController.text.trim();
                              if (name.isNotEmpty) {
                                await _db.collection('tasks').add({
                                  'name': name,
                                  'priority': _selectedPriority,
                                  'finished': false,
                                });
                                _nameController.clear();
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Salvar'),
                        ),
                      ),
                    ]
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
