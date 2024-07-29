import 'package:flutter/material.dart';

void main() {
  runApp(FlashcardQuizApp());
}

class FlashcardQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      home: FlashcardHomePage(),
    );
  }
}

class FlashcardHomePage extends StatefulWidget {
  @override
  _FlashcardHomePageState createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage> {
  final List<Flashcard> flashcards = [];
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  int correctAnswers = 0;
  int currentIndex = 0;
  bool inQuizMode = false;
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Quiz App'),
        actions: [
          IconButton(
            icon: Icon(inQuizMode ? Icons.exit_to_app : Icons.quiz),
            onPressed: () {
              setState(() {
                inQuizMode = !inQuizMode;
                if (inQuizMode) {
                  _startQuiz();
                } else {
                  _resetQuiz();
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: inQuizMode ? _buildQuizMode() : _buildFlashcardList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFlashcardList() {
    return Column(
      children: [
        Expanded(
          child: flashcards.isEmpty
              ? Center(child: Text('No flashcards added yet!'))
              : ListView.builder(
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.grey[800],
                      child: ListTile(
                        title: Text(flashcards[index].question),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFlashcard(index),
                        ),
                        onTap: () => _editFlashcard(index),
                      ),
                    );
                  },
                ),
        ),
        _buildInputFields(),
      ],
    );
  }

  Widget _buildQuizMode() {
    if (flashcards.isEmpty) {
      return Center(child: Text('No flashcards available for the quiz!'));
    }

    final flashcard = flashcards[currentIndex];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(flashcard.question, style: TextStyle(fontSize: 24)),
        SizedBox(height: 20),
        _buildAnswerOptions(),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _checkAnswer,
          child: Text('Submit Answer'),
        ),
        SizedBox(height: 20),
        Text('Score: $correctAnswers/${currentIndex + 1}'),
      ],
    );
  }

  Widget _buildAnswerOptions() {
    final options = List<String>.from(flashcards.map((fc) => fc.answer))..shuffle();
    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: selectedAnswer,
          onChanged: (value) {
            setState(() {
              selectedAnswer = value;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          controller: questionController,
          decoration: InputDecoration(
            labelText: 'Question',
            fillColor: Colors.grey[800],
            filled: true,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: answerController,
          decoration: InputDecoration(
            labelText: 'Answer',
            fillColor: Colors.grey[800],
            filled: true,
          ),
        ),
      ],
    );
  }

  void _addFlashcard() {
    final question = questionController.text;
    final answer = answerController.text;

    if (question.isNotEmpty && answer.isNotEmpty) {
      setState(() {
        flashcards.add(Flashcard(question: question, answer: answer));
      });
      questionController.clear();
      answerController.clear();
    }
  }

  void _editFlashcard(int index) {
    final flashcard = flashcards[index];
    questionController.text = flashcard.question;
    answerController.text = flashcard.answer;

    setState(() {
      flashcards.removeAt(index);
    });
  }

  void _deleteFlashcard(int index) {
    setState(() {
      flashcards.removeAt(index);
    });
  }

  void _startQuiz() {
    setState(() {
      flashcards.shuffle();
      correctAnswers = 0;
      currentIndex = 0;
      selectedAnswer = null;
    });
  }

  void _resetQuiz() {
    setState(() {
      correctAnswers = 0;
      currentIndex = 0;
      selectedAnswer = null;
    });
  }

  void _checkAnswer() {
    if (selectedAnswer == flashcards[currentIndex].answer) {
      correctAnswers++;
    }
    setState(() {
      if (currentIndex < flashcards.length - 1) {
        currentIndex++;
        selectedAnswer = null;
      } else {
        _showQuizSummary();
        inQuizMode = false;
      }
    });
  }

  void _showQuizSummary() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Summary'),
          content: Text('You scored $correctAnswers out of ${flashcards.length}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetQuiz();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}
