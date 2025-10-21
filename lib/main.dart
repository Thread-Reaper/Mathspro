// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(MathsPro());
// }

// class MathsPro extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MathsPro Game',
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primaryColor: Colors.blueAccent,
//         scaffoldBackgroundColor: Colors.black,
//         textTheme: const TextTheme(
//           bodyLarge: TextStyle(color: Colors.white),
//           bodyMedium: TextStyle(color: Colors.white),
//           headlineLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           hintStyle: TextStyle(color: Colors.grey),
//           filled: true,
//           fillColor: Colors.black26,
//           border: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//         ),
//         buttonTheme: ButtonThemeData(
//           buttonColor: Colors.blueAccent,
//           textTheme: ButtonTextTheme.primary,
//         ),
//       ),
//       home: MathGameScreen(),
//     );
//   }
// }

// class MathGameScreen extends StatefulWidget {
//   @override
//   _MathGameScreenState createState() => _MathGameScreenState();
// }

// class _MathGameScreenState extends State<MathGameScreen> with TickerProviderStateMixin {
//   int numQuestions = 1;
//   int timeLimit = 0;
//   String operator = '+';
//   String difficulty = 'Easy';
//   String question = '';
//   String answer = '';
//   String feedback = '';
//   int correctAnswers = 0;
//   int totalQuestions = 0;

//   late Timer _timer;
//   int remainingTime = 0;

//   late AnimationController _questionController;
//   late AnimationController _feedbackController;
//   late Animation<double> _questionOpacity;
//   late Animation<double> _feedbackOpacity;

//   List<Map<String, dynamic>> history = [];

//   @override
//   void initState() {
//     super.initState();

//     _questionController = AnimationController(duration: Duration(seconds: 1), vsync: this);
//     _questionOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_questionController);

//     _feedbackController = AnimationController(duration: Duration(seconds: 1), vsync: this);
//     _feedbackOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_feedbackController);

//     _questionController.forward();

//     _generateQuestion();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _questionController.dispose();
//     _feedbackController.dispose();
//     super.dispose();
//   }

//   // Generate random math question based on difficulty and operator
//   void _generateQuestion() {
//     Random random = Random();

//     int num1 = _generateNumberBasedOnDifficulty();
//     int num2 = _generateNumberBasedOnDifficulty();

//     // Random operator
//     List<String> operators = ['+', '-', '*', '/'];
//     operator = operators[random.nextInt(operators.length)];

//     question = "$num1 $operator $num2";

//     remainingTime = timeLimit > 0 ? timeLimit : 30;

//     setState(() {});

//     if (timeLimit > 0) {
//       _startTimer();
//     }
//   }

//   int _generateNumberBasedOnDifficulty() {
//     Random random = Random();

//     switch (difficulty) {
//       case 'Easy':
//         return random.nextInt(90) + 10; // Two-digit numbers
//       case 'Medium':
//         return random.nextInt(9000) + 1000; // Three to four-digit numbers
//       case 'Hard':
//         return random.nextInt(90000) + 10000; // Four to five-digit numbers
//       case 'Extreme':
//         return random.nextInt(90000000) + 10000000; // Five to eight-digit numbers
//       default:
//         return random.nextInt(100) + 10;
//     }
//   }

//   // Start the countdown timer
//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (remainingTime > 0) {
//         setState(() {
//           remainingTime--;
//         });
//       } else {
//         _timer.cancel();
//         _nextQuestion();
//       }
//     });
//   }

//   // Handle user answer submission
//   void _submitAnswer() {
//     int correctAnswer = _calculateAnswer();
//     int userAnswer = int.tryParse(answer) ?? 0;

//     setState(() {
//       if (userAnswer == correctAnswer) {
//         feedback = "Correct!";
//         correctAnswers++;
//       } else {
//         feedback = "Incorrect!";
//       }

//       totalQuestions++;
//       _feedbackController.forward();
//       history.add({
//         'question': question,
//         'correct': feedback == 'Correct!',
//       });

//       _generateQuestion();
//     });
//   }

//   // Calculate the correct answer based on the operator
//   int _calculateAnswer() {
//     int num1 = int.parse(question.split(' ')[0]);
//     int num2 = int.parse(question.split(' ')[2]);

//     switch (operator) {
//       case '+':
//         return num1 + num2;
//       case '-':
//         return num1 - num2;
//       case '*':
//         return num1 * num2;
//       case '/':
//         return num1 ~/ num2; // Integer division
//       default:
//         return 0;
//     }
//   }

//   // Go to the next question
//   void _nextQuestion() {
//     setState(() {
//       _generateQuestion();
//       feedback = '';
//       answer = '';
//     });
//   }

//   // Navigate to History Page
//   void _viewHistory() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => HistoryPage(history: history)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('MathsPro Game'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.history),
//             onPressed: _viewHistory,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             FadeTransition(
//               opacity: _questionOpacity,
//               child: Text(
//                 'Math Question: $question',
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               onChanged: (text) {
//                 setState(() {
//                   answer = text;
//                 });
//               },
//               keyboardType: TextInputType.number, // Restrict to numbers
//               decoration: InputDecoration(
//                 hintText: 'Enter your answer',
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _submitAnswer,
//               child: Text('Submit Answer'),
//             ),
//             SizedBox(height: 20),
//             FadeTransition(
//               opacity: _feedbackOpacity,
//               child: Text(
//                 feedback,
//                 style: TextStyle(fontSize: 18, color: Colors.green),
//               ),
//             ),
//             SizedBox(height: 20),
//             if (timeLimit > 0)
//               Text(
//                 'Time Remaining: $remainingTime',
//                 style: TextStyle(fontSize: 16, color: Colors.red),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class HistoryPage extends StatelessWidget {
//   final List<Map<String, dynamic>> history;
//   HistoryPage({required this.history});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Game History')),
//       body: ListView.builder(
//         itemCount: history.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text('Question: ${history[index]['question']}'),
//             subtitle: Text('Correct: ${history[index]['correct']}'),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: ThemeController.notifier,
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'MathsPro Game',
          theme: theme,
          home: SplashScreen(),
        );
      },
    );
  }
}
