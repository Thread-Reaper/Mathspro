import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  final String userName;

  MainScreen({required this.userName});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int numQuestions = 1;
  int timeLimit = 0;
  String operator = '+';
  String difficulty = 'Easy';

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Setup your quiz', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // Number of Questions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Number of questions'),
                DropdownButton<int>(
                  value: numQuestions,
                  onChanged: (value) {
                    setState(() { numQuestions = value!; });
                  },
                  items: List.generate(100, (index) => index + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                ),
              ],
            ),
            const Divider(height: 24),
            // Time Limit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time limit (per question)'),
                DropdownButton<int>(
                  value: timeLimit,
                  onChanged: (value) {
                    setState(() { timeLimit = value!; });
                  },
                  items: [0, 10, 20, 30, 60]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == 0 ? 'Unlimited' : '$e s'),
                          ))
                      .toList(),
                ),
              ],
            ),
            const Divider(height: 24),
            // Operations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Operation'),
                DropdownButton<String>(
                  value: operator,
                  onChanged: (value) {
                    setState(() { operator = value!; });
                  },
                  items: ['+', '-', '*', '/', 'All']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ],
            ),
            const Divider(height: 24),
            // Difficulty
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Difficulty'),
                DropdownButton<String>(
                  value: difficulty,
                  onChanged: (value) {
                    setState(() { difficulty = value!; });
                  },
                  items: ['Easy', 'Medium', 'Hard', 'Extreme']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        numQuestions: numQuestions,
                        timeLimit: timeLimit,
                        operator: operator,
                        difficulty: difficulty,
                        userName: widget.userName,
                      ),
                    ),
                  );
                },
                child: const Text('Start quiz'),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              width: 28,
              height: 28,
              errorBuilder: (c, e, s) => const Icon(Icons.calculate),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Welcome ${widget.userName}')),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: card,
          ),
        ),
      ),
    );
  }
}
