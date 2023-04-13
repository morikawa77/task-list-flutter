class Task {
  String? id;
  String? name;
  String? priority;
  bool? finished;
  // String? selectedPriority;

  // Task(this.id, this.name, {this.priority = 'low', this.finished = false, this.selectedPriority});
  Task(this.id, this.name, {this.priority = 'low', this.finished = false});
}
