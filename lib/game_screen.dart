import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_screen.dart';

class GameScreen extends StatefulWidget {
  final int numQuestions;
  final int timeLimit;
  final String operator;
  final String difficulty;
  final String userName;

  GameScreen({
    required this.numQuestions,
    required this.timeLimit,
    required this.operator,
    required this.difficulty,
    required this.userName,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentQuestion = 1;
  int correctAnswers = 0;
  String question = '';
  final TextEditingController _answerController = TextEditingController();
  String? inputError;
  String feedback = '';
  int remainingTime = 0;

  Timer? _timer;
  final List<Map<String, dynamic>> _attempts = [];

  // Hold-to-submit state
  Timer? _holdTimer;
  bool _holding = false;
  double _holdProgress = 0.0; // 0..1
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    remainingTime = widget.timeLimit > 0 ? widget.timeLimit : 0;
    if (widget.timeLimit > 0) {
      _startTimer();
    }
  }

  int _randInDigits(int minDigits, int maxDigits) {
    final rnd = Random();
    final d = minDigits + rnd.nextInt(maxDigits - minDigits + 1);
    final min = pow(10, d - 1).toInt();
    final max = pow(10, d).toInt() - 1;
    return min + rnd.nextInt(max - min + 1);
  }

  int _genByDifficulty() {
    switch (widget.difficulty) {
      case 'Easy':
        return _randInDigits(2, 2);
      case 'Medium':
        return _randInDigits(3, 4);
      case 'Hard':
        return _randInDigits(4, 5);
      case 'Extreme':
        return _randInDigits(5, 8);
      default:
        return _randInDigits(2, 2);
    }
  }

  int _randExactDigits(int digits) => _randInDigits(digits, digits);

  String _pickOperator() {
    if (widget.operator == 'All') {
      const ops = ['+', '-', '*', '/'];
      return ops[Random().nextInt(ops.length)];
    }
    return widget.operator;
  }

  // Generate a division pair (a / b) with exact digit counts per difficulty,
  // ensuring an integer result.
  // Easy:    3/1  digits
  // Medium:  3/2  digits
  // Hard:    4/2  digits
  // Extreme: 5/2 or 6/2 digits
  (int, int) _divisionPairForDifficulty() {
    int dividendDigits;
    int divisorDigits;
    if (widget.difficulty == 'Easy') {
      dividendDigits = 3; divisorDigits = 1;
    } else if (widget.difficulty == 'Medium') {
      dividendDigits = 3; divisorDigits = 2;
    } else if (widget.difficulty == 'Hard') {
      dividendDigits = 4; divisorDigits = 2;
    } else {
      // Extreme
      dividendDigits = Random().nextBool() ? 5 : 6;
      divisorDigits = 2;
    }

    final rnd = Random();

    int minDivisor = pow(10, divisorDigits - 1).toInt();
    int maxDivisor = pow(10, divisorDigits).toInt() - 1;
    // Avoid divisor 0 and 1 to keep it meaningful
    minDivisor = max(2, minDivisor);

    int minDividend = pow(10, dividendDigits - 1).toInt();
    int maxDividend = pow(10, dividendDigits).toInt() - 1;

    for (int tries = 0; tries < 1000; tries++) {
      final b = minDivisor + rnd.nextInt(max(1, maxDivisor - minDivisor + 1));
      // k range to keep product's digits exact
      final minK = ((minDividend + b - 1) ~/ b); // ceil(minDividend / b)
      final maxK = (maxDividend ~/ b);
      if (minK <= maxK && maxK >= 2) {
        final lo = max(2, minK);
        final hi = maxK;
        if (lo <= hi) {
          final k = lo + rnd.nextInt(hi - lo + 1);
          final a = b * k;
          if (a >= minDividend && a <= maxDividend) {
            return (a, b);
          }
        }
      }
    }
    // Fallback if no exact pair found quickly
    final b = max(2, minDivisor);
    final a = b * 10;
    return (a, b);
  }

  void _generateQuestion() {
    final rnd = Random();
    int a = _genByDifficulty();
    int b = _genByDifficulty();
    final op = _pickOperator();

    switch (op) {
      case '+':
        question = "$a + $b";
        break;
      case '-':
        // ensure non-negative result
        if (a < b) {
          final t = a; a = b; b = t;
        }
        question = "$a - $b";
        break;
      case '*':
        final pair = _multiplicationPairForDifficulty();
        a = pair.$1; b = pair.$2;
        question = "$a * $b";
        break;
      case '/':
        final pair = _divisionPairForDifficulty();
        a = pair.$1; b = pair.$2;
        question = "$a / $b";
        break;
      default:
        question = "$a + $b";
        break;
    }

    setState(() {
      isAnswered = false;
      inputError = null;
      _answerController.clear();
      feedback = '';
    });
  }

  // Multiplication digit rules per difficulty
  // Easy:    3*1 or 4*1 or 5*1
  // Medium:  3*2 or 4*2
  // Hard:    4*3 or 5*3
  // Extreme: 5*3 or 6*3 or 7*3
  (int, int) _multiplicationPairForDifficulty() {
    final rnd = Random();
    late List<int> firstChoices;
    late int secondDigits;
    switch (widget.difficulty) {
      case 'Easy':
        firstChoices = [3, 4, 5];
        secondDigits = 1;
        break;
      case 'Medium':
        firstChoices = [3, 4];
        secondDigits = 2;
        break;
      case 'Hard':
        firstChoices = [4, 5];
        secondDigits = 3;
        break;
      case 'Extreme':
        firstChoices = [5, 6, 7];
        secondDigits = 3;
        break;
      default:
        firstChoices = [3];
        secondDigits = 1;
    }
    final firstDigits = firstChoices[rnd.nextInt(firstChoices.length)];
    final a = _randExactDigits(firstDigits);
    int b;
    if (secondDigits == 1) {
      // avoid trivial 0/1 multipliers; pick 2..9
      b = 2 + rnd.nextInt(8);
    } else {
      b = _randExactDigits(secondDigits);
    }
    return (a, b);
  }

  Future<void> _submitAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty || int.tryParse(text) == null) {
      setState(() {
        inputError = 'Please enter numbers only';
      });
      return;
    }
    final userAnswer = int.parse(text);
    final correctAnswer = _calculateAnswer();

    final isCorrect = userAnswer == correctAnswer;
    final bool isLast = currentQuestion >= widget.numQuestions;
    setState(() {
      if (isCorrect) {
        feedback = 'Correct!';
        correctAnswers++;
      } else {
        feedback = 'Incorrect!';
      }
      _attempts.add({
        'question': question,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'isCorrect': isCorrect,
      });
    });

    // Briefly show feedback before moving on
    await Future.delayed(const Duration(milliseconds: 700));

    if (!isLast) {
      if (widget.timeLimit > 0) {
        _timer?.cancel();
        remainingTime = widget.timeLimit;
        _startTimer();
      }
      setState(() {
        currentQuestion++;
      });
      _generateQuestion();
    } else {
      _endGame();
    }
  }

  int _calculateAnswer() {
    List<String> parts = question.split(' ');
    int num1 = int.parse(parts[0]);
    int num2 = int.parse(parts[2]);

    switch (parts[1]) {
      case '+':
        return num1 + num2;
      case '-':
        return num1 - num2;
      case '*':
        return num1 * num2;
      case '/':
        return num1 ~/ num2;
      default:
        return 0;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        _timer?.cancel();
        // Record timeout as incorrect attempt
        final correctAnswer = _calculateAnswer();
        final bool isLast = currentQuestion >= widget.numQuestions;
        _attempts.add({
          'question': question,
          'userAnswer': null,
          'correctAnswer': correctAnswer,
          'isCorrect': false,
        });
        if (!isLast) {
          currentQuestion++;
          remainingTime = widget.timeLimit;
          _startTimer();
          _generateQuestion();
        } else {
          _endGame();
        }
      }
    });
  }

  void _endGame() async {
    // Save result
    await _saveResult();
    // Show a bottom sheet with score and incorrect answers with corrections
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final incorrect = _attempts.where((a) => a['isCorrect'] == false).toList();
        final total = widget.numQuestions;
        final correct = correctAnswers;
        final percent = total > 0 ? ((correct * 100) / total).round() : 0;
        String remark;
        if (percent >= 90) {
          remark = 'Outstanding! 🎉 Keep it up.';
        } else if (percent >= 75) {
          remark = 'Great job! 👍 You\'re nearly there.';
        } else if (percent >= 60) {
          remark = 'Good effort. Keep practicing!';
        } else if (percent >= 40) {
          remark = 'You\'re improving. Practice makes perfect.';
        } else {
          remark = 'Don\'t give up — try again! 💪';
        }
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quiz Complete', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Score: $correct / $total ($percent%)'),
                  const SizedBox(height: 4),
                  Text(remark, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  if (incorrect.isNotEmpty)
                    Text('Review incorrect answers', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Expanded(
                    child: incorrect.isEmpty
                        ? const Center(child: Text('All answers were correct!'))
                        : ListView.builder(
                            controller: controller,
                            itemCount: incorrect.length,
                            itemBuilder: (context, index) {
                              final a = incorrect[index];
                              return Card(
                                child: ListTile(
                                  title: Text(a['question'] as String),
                                  subtitle: Text('Your answer: ' + (a['userAnswer']?.toString() ?? '—') + '\nCorrect answer: ' + (a['correctAnswer']).toString()),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('Show previous results'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // close sheet
                          Navigator.of(context).pop(); // back to main
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveResult() async {
    final incorrect = _attempts
        .where((a) => a['isCorrect'] == false)
        .map((a) => {
              'question': a['question'],
              'userAnswer': a['userAnswer'],
              'correctAnswer': a['correctAnswer'],
            })
        .toList();
    final record = {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'userName': widget.userName,
      'score': correctAnswers,
      'total': widget.numQuestions,
      'operator': widget.operator,
      'difficulty': widget.difficulty,
      'timeLimit': widget.timeLimit,
      'incorrect': incorrect,
    };
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('quiz_history') ?? [];
    list.add(jsonEncode(record));
    await prefs.setStringList('quiz_history', list);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formLikeCard = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Question $currentQuestion of ${widget.numQuestions}', style: Theme.of(context).textTheme.titleMedium),
            if (widget.timeLimit > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Time remaining: $remainingTime s', style: Theme.of(context).textTheme.bodySmall),
              ),
            const Divider(height: 24),
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Instructions:', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('• Don\'t use a calculator'),
                  Text('• Calculate on a notebook'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation);
                return SlideTransition(position: offset, child: child);
              },
              child: Column(
                key: ValueKey('q-'+currentQuestion.toString()+'-'+question),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Big, high-contrast equation that auto-shrinks if needed
                  SizedBox(
                    height: 100,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 64, // ~2x bigger baseline
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _answerController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Your answer',
                      helperText: 'Numbers only',
                      errorText: inputError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTapDown: (_) {
                        if (_holdTimer != null) return; // already holding
                        setState(() { _holding = true; _holdProgress = 0; });
                        final start = DateTime.now();
                        _holdTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
                          final elapsed = DateTime.now().difference(start).inMilliseconds;
                          final p = elapsed / 1000.0;
                          if (p >= 1.0) {
                            t.cancel();
                            _holdTimer = null;
                            setState(() { _holding = false; _holdProgress = 0; });
                            _submitAnswer();
                          } else {
                            setState(() { _holdProgress = p; });
                          }
                        });
                      },
                      onTapUp: (_) {
                        _holdTimer?.cancel();
                        _holdTimer = null;
                        setState(() { _holding = false; _holdProgress = 0; });
                      },
                      onTapCancel: () {
                        _holdTimer?.cancel();
                        _holdTimer = null;
                        setState(() { _holding = false; _holdProgress = 0; });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: CircularProgressIndicator(
                              value: _holding ? _holdProgress : 0,
                              strokeWidth: 6,
                            ),
                          ),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: const Center(
                              child: Text(
                                'Submit',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (feedback.isNotEmpty)
                    Center(
                      child: Text(
                        feedback,
                        style: TextStyle(
                          color: feedback == 'Correct!' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz — ${widget.userName}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: formLikeCard,
          ),
        ),
      ),
    );
  }
}
