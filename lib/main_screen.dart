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
            Text(
              'Setup your quiz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Number of Questions (slider to avoid huge dropdown)
            Text('Questions: $numQuestions', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: numQuestions.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: '$numQuestions',
              onChanged: (v) => setState(() => numQuestions = v.round()),
            ),
            const Divider(height: 24),
            // Time Limit
            DropdownButtonFormField<int>(
              value: timeLimit,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Time limit (per question)',
              ),
              onChanged: (value) {
                setState(() { timeLimit = value!; });
              },
              items: [0, 10, 20, 30, 50, 60, 70, 80, 100]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e == 0 ? 'Unlimited' : '$e s')))
                  .toList(),
            ),
            const Divider(height: 24),
            // Operations
            DropdownButtonFormField<String>(
              value: operator,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Operation',
              ),
              onChanged: (value) {
                setState(() { operator = value!; });
              },
              items: const [
                DropdownMenuItem(value: '+', child: Text('Addition (+)')),
                DropdownMenuItem(value: '-', child: Text('Subtraction (-)')),
                DropdownMenuItem(value: '*', child: Text('Multiplication (×)')),
                DropdownMenuItem(value: '/', child: Text('Division (÷)')),
                DropdownMenuItem(value: 'All', child: Text('All')),
              ],
            ),
            const Divider(height: 24),
            // Difficulty
            DropdownButtonFormField<String>(
              value: difficulty,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Difficulty',
              ),
              onChanged: (value) {
                setState(() { difficulty = value!; });
              },
              items: const [
                DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                DropdownMenuItem(value: 'Extreme', child: Text('Extreme (Big Numbers)')),
              ],
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: Tooltip(
                message: 'Start Quiz',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(36),
                  ),
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
                  child: const Icon(Icons.play_arrow, size: 48),
                ),
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
              'assets/app_logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
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
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: card,
          ),
        ),
      ),
    );
  }
}
