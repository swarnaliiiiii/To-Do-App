import 'package:flutter/material.dart';
import 'package:flutter_application_1/Task_Detail.dart';
import 'dart:math';

import 'package:flutter_application_1/Task_Screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller with a repeating animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // 5-second animation cycle
    )..repeat(); // Infinite rotation effect
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F5), // Light neutral background
      body: Stack(
        children: [
          // Background animated sphere
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateY(_animationController.value * 2 * pi)
                    ..rotateX(_animationController.value * pi),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color.fromRGBO(128, 0, 128, 0.6), // Purple
                          Color.fromRGBO(0, 0, 255, 0.4),   // Blue
                          Color.fromRGBO(0, 0, 0, 0.3),     // Black
                        ],
                        center: Alignment.center,
                        radius: 1.5, // Large radius to fill background
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom container with "Get Started" button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.35, // Responsive height
              decoration: BoxDecoration(
                color: Colors.black87, // Subtle dark gray background
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manage',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: const [
                            Text(
                              'your ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'tasks',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Get Started Button
                    GestureDetector(
                      onTap: () {
                        // Navigate to the ChoosePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                              title: 'Good Work!',
                              description: 'You have successfully created a new task. Keep up the good work! Slide to delete the task or tap to view details.',
                              progress: 0.5,
                              priority: '',
                              dueDate: DateTime.now().add(Duration(days: 7)), dueTime: '12:00 PM',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade600,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
