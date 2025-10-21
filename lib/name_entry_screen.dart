import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameEntryScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  void _saveNameAndNavigate(BuildContext context) async {
    String name = _controller.text.trim();
    if (name.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(userName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Your Name')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveNameAndNavigate(context),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
