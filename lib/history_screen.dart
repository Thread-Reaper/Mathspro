import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('quiz_history') ?? [];
    setState(() {
      _items = list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList().reversed.toList();
    });
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_history');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Results'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_outline),
            onPressed: _items.isEmpty
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear history?'),
                        content: const Text('This will remove all saved results.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                        ],
                      ),
                    );
                    if (ok == true) await _clearAll();
                  },
          )
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('No previous results yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final score = item['score'] as int? ?? 0;
                final total = item['total'] as int? ?? 0;
                final percent = total > 0 ? ((score * 100) / total).round() : 0;
                final ts = DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now();
                final subtitle = 'Op: ${item['operator']}   Diff: ${item['difficulty']}   Time: ${item['timeLimit'] == 0 ? 'Unlimited' : '${item['timeLimit']}s'}';
                final incorrect = (item['incorrect'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Text('${ts.toLocal()}'.split('.').first),
                    subtitle: Text(subtitle),
                    trailing: Text('$score/$total  ($percent%)'),
                    children: [
                      if (incorrect.isEmpty)
                        const ListTile(title: Text('All answers were correct!'))
                      else
                        ...incorrect.map((a) => ListTile(
                              title: Text(a['question'] as String),
                              subtitle: Text('Your: ${a['userAnswer'] ?? '—'}    Correct: ${a['correctAnswer']}'),
                            )),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

