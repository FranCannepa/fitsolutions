import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Add functionality for buttons here (optional)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Three Button Layout'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Add your button 1 functionality here
                print('Button 1 Pressed');
              },
              child: Text('Button 1'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your button 2 functionality here
                print('Button 2 Pressed');
              },
              child: Text('Button 2'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your button 3 functionality here
                print('Button 3 Pressed');
              },
              child: Text('Button 3'),
            ),
          ],
        ),
      ),
    );
  }
}
