import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String temperature;
  const HomeScreen({super.key, required this.temperature});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Current Temperature: ${widget.temperature}', //in  state class use widget property to access fiields from parent StatefulWidget
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
