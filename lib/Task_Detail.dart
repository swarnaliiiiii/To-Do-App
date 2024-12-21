import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Task_Screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final double progress;
  final String priority;
  final DateTime dueDate;
  final String dueTime;
  final String? taskId;

  const TaskDetailScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.progress,
    required this.priority,
    required this.dueDate,
    required this.dueTime,
    this.taskId,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Stream<QuerySnapshot> _tasksStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tasksStream = _firestore
        .collection('task')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _firestore.collection('task').doc(taskId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateTaskStatus(String taskId, bool isCompleted) async {
    try {
      await _firestore.collection('task').doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      print('Error updating task status: $e');
    }
  }

  Future<void> _addSubtask(String taskId, String subtaskTitle) async {
    try {
      await _firestore.collection('task').doc(taskId).update({
        'subtasks': FieldValue.arrayUnion([{
          'title': subtaskTitle,
          'isCompleted': false,
        }]),
      });
    } catch (e) {
      print('Error adding subtask: $e');
    }
  }

  Widget _buildCategoryChips() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildChip('All', Icons.all_inclusive),
            const SizedBox(width: 12),
            _buildChip('Today', Icons.today),
            const SizedBox(width: 12),
            _buildChip('Tomorrow', Icons.calendar_today),
            const SizedBox(width: 12),
            _buildChip('Next Week', Icons.date_range),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    bool isSelected = selectedCategory == label;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.purple,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            selectedCategory = value ? label : 'All';
          });
        },
        backgroundColor: Colors.purple.withOpacity(0.1),
        selectedColor: Colors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.purple,
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: isSelected ? 2 : 0,
        pressElevation: 4,
      ),
    );
  }

  List<Map<String, dynamic>> filterTasks(
    List<Map<String, dynamic>> tasks,
    String category,
    DateTime today,
  ) {
    switch (category) {
      case 'Today':
        return tasks.where((task) {
          final taskDate = (task['dueDate'] as Timestamp).toDate();
          return taskDate.day == today.day &&
              taskDate.month == today.month &&
              taskDate.year == today.year;
        }).toList();
      case 'Tomorrow':
        return tasks.where((task) {
          final taskDate = (task['dueDate'] as Timestamp).toDate();
          final tomorrow = today.add(Duration(days: 1));
          return taskDate.day == tomorrow.day &&
              taskDate.month == tomorrow.month &&
              taskDate.year == tomorrow.year;
        }).toList();
      case 'Next Week':
        return tasks.where((task) {
          final taskDate = (task['dueDate'] as Timestamp).toDate();
          final nextWeek = today.add(Duration(days: 7));
          return taskDate.isAfter(today.add(Duration(days: 1))) &&
              taskDate.isBefore(nextWeek);
        }).toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.purple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Task',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskCreationScreen()),
          );
        },
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _tasksStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  );
                }

                final tasks = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {...data, 'taskId': doc.id};
                }).toList();

                final filteredTasks = filterTasks(tasks, selectedCategory, today);

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No tasks found(slide to delete)',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return _buildTaskCard(task, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, int index) {
    final List<Color> cardColors = [
      Color(0xFFE6E6FA),
      Color(0xFFFFDAB9),
      Color(0xFFE0FFFF),
      Color(0xFFF0FFF0),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColors[index % cardColors.length],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Dismissible(
        key: Key(task['taskId']),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("Delete Task"),
              content: Text("Are you sure you want to delete this task?"),
              actions: [
                TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) => _deleteTask(task['taskId']),
        child: TaskListItem(
          taskId: task['taskId'],
          title: task['title'] ?? '',
          description: task['description'] ?? '',
          isCompleted: task['isCompleted'] ?? false,
          onDelete: () => _deleteTask(task['taskId']),
          onToggle: (bool value) => _updateTaskStatus(task['taskId'], value),
          onAddSubtask: (String subtaskTitle) =>
              _addSubtask(task['taskId'], subtaskTitle),
        ),
      ),
    );
  }
}

class TaskListItem extends StatefulWidget {
  final String taskId;
  final String title;
  final String description;
  final bool isCompleted;
  final VoidCallback onDelete;
  final Function(bool) onToggle;
  final Function(String) onAddSubtask;

  const TaskListItem({
    Key? key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.onDelete,
    required this.onToggle,
    required this.onAddSubtask,
  }) : super(key: key);

  @override
  _TaskListItemState createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  List<String> _subtasks = [];
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: widget.isCompleted,
                  onChanged: (bool? value) {
                    if (value != null) widget.onToggle(value);
                  },
                  activeColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
                        color: widget.isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    if (widget.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_task, size: 20),
                onPressed: () => _showAddSubtaskDialog(context),
                color: Colors.purple,
              ),
            ],
          ),
          if (_subtasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _subtasks.map((subtask) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      subtask,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddSubtaskDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Subtask Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _subtasks.add(controller.text);
              });
              widget.onAddSubtask(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}