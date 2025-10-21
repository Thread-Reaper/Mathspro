import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'history_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import 'package:flutter/widgets.dart';

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
  late final TextEditingController _qController;
  late FixedExtentScrollController _qWheelController;
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _qController = TextEditingController(text: numQuestions.toString());
    _qWheelController = FixedExtentScrollController(initialItem: numQuestions - 1);
    _displayName = widget.userName;
  }

  @override
  void dispose() {
    _qController.dispose();
    _qWheelController.dispose();
    super.dispose();
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Your name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', newName);
      if (!mounted) return;
      setState(() {
        _displayName = newName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Setup your quiz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            // Number of Questions (wheel picker + numeric input)
            Text('Questions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 108, // show center + one above/below
                    child: ListWheelScrollView.useDelegate(
                      controller: _qWheelController,
                      physics: const FixedExtentScrollPhysics(),
                      itemExtent: 36,
                      perspective: 0.003,
                      onSelectedItemChanged: (i) {
                        setState(() {
                          numQuestions = i + 1;
                          _qController.text = numQuestions.toString();
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index >= 100) return null;
                          final value = index + 1;
                          final bool selected = value == numQuestions;
                          final theme = Theme.of(context).colorScheme;
                          return Center(
                            child: Text(
                              '$value',
                              style: TextStyle(
                                fontSize: selected ? 24 : 18, // ~1.33x bigger when selected
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                color: selected ? theme.primary : theme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          );
                        },
                        childCount: 100,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: _qController,
                    maxLength: 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      counterText: '',
                      labelText: '1-100',
                    ),
                    onChanged: (val) {
                      final raw = int.tryParse(val);
                      if (raw == null) return;
                      final clamped = raw.clamp(1, 100);
                      if (clamped != numQuestions) {
                        setState(() { numQuestions = clamped; });
                        _qWheelController.animateToItem(
                          clamped - 1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    onSubmitted: (val) {
                      final n = int.tryParse(val) ?? numQuestions;
                      final clamped = n.clamp(1, 100);
                      _qController.text = clamped.toString();
                      setState(() { numQuestions = clamped; });
                      _qWheelController.animateToItem(
                        clamped - 1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 32),
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
            const SizedBox(height: 32),
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
            const SizedBox(height: 44),
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
            Expanded(child: Text('Welcome $_displayName')),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            iconSize: 22,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 32),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Edit name',
            iconSize: 22,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 32),
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editName,
          ),
          IconButton(
            tooltip: 'History',
            iconSize: 22,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 32),
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
            child: content,
          ),
        ),
      ),
    );
  }
}
