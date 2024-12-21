import 'package:flutter/material.dart';
import 'package:flutter_application_1/store_data.dart';

class TaskCreationScreen extends StatefulWidget {
  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  String priority = 'NORMAL';
  DateTime selectedDate = DateTime.now();
  TimeOfDay estimatedTime = TimeOfDay(hour: 16, minute: 0);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final labelStyle = TextStyle(color: Colors.grey[400], fontSize: 14);

  @override
  void initState() {
    super.initState();
    _resetForm(); // Clear the form when the screen is loaded
  }

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    setState(() {
      priority = 'NORMAL';
      selectedDate = DateTime.now();
      estimatedTime = TimeOfDay(hour: 16, minute: 0);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: estimatedTime);
    if (picked != null) setState(() => estimatedTime = picked);
  }

  Widget _buildInputField(String label, {String? hint, bool multiline = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: multiline ? 4 : 1,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButton(String text) {
    final isSelected = priority == text;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => priority = text),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color.fromARGB(255, 168, 88, 182) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Colors.transparent : const Color.fromARGB(255, 162, 85, 175),
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey[400]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 8, 11),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
    ),
    TextButton(
      onPressed: () {
        _resetForm(); // Clear all input fields
      },
      child: Text(
        'New Task',
        style: TextStyle(color: Colors.grey[400]),
      ),
    ),
  ],
),
const SizedBox(height: 24),

              // Input Fields
              _buildInputField('Title', hint: 'Subject for your new task', controller: titleController),
              const SizedBox(height: 24),
              _buildInputField('Description', hint: 'Add a description', multiline: true, controller: descriptionController),
              const SizedBox(height: 24),

              // Due Date & Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Due date', style: labelStyle),
                        GestureDetector(
                          onTap: _pickDate,
                          child: _buildInfoBox(
                            content: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimate time', style: labelStyle),
                        GestureDetector(
                          onTap: _pickTime,
                          child: _buildInfoBox(
                            content: '${estimatedTime.hour}h ${estimatedTime.minute}m',
                            icon: Icons.access_time,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Priority Selection
              Text('Priority', style: labelStyle),
              const SizedBox(height: 8),
              Row(
                children: ['URGENT', 'NORMAL', 'LOW']
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildPriorityButton(p),
                        ))
                    .toList(),
              ),
              const Spacer(),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    // Capture task details
                    String taskid = DateTime.now().millisecondsSinceEpoch.toString();
                    String taskTitle = titleController.text;
                    String taskDescription = descriptionController.text;
                    DateTime taskDueDate = selectedDate;
                    String taskDueTime = '${estimatedTime.hour}h ${estimatedTime.minute}m';
                    String taskPriority = priority;

                    // Save task to Firestore
                    await saveTaskToFirestore(
                      taskid: taskid,
                      title: taskTitle,
                      description: taskDescription,
                      dueDate: taskDueDate,
                      dueTime: taskDueTime,
                      priority: taskPriority,
                    );

                    // Reset form after saving
                    _resetForm();

                    // Close the screen after saving task
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 168, 85, 182),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Create Task',
                    style: TextStyle(
                      color: Color.fromARGB(255, 247, 244, 244),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(content, style: const TextStyle(color: Colors.white)),
          Icon(icon, color: const Color.fromARGB(255, 165, 81, 180), size: 16),
        ],
      ),
    );
  }
}
