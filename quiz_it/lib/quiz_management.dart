import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quizit/utilities.dart';
import 'package:quizit/web_socket_connection.dart';
import 'custom_widgets.dart';
import 'dart:async';
import 'package:cloudinary_public/cloudinary_public.dart';

final cloudinary = CloudinaryPublic('quizit', 'yxld7cc2', cache: false);

class QuizManagement extends StatefulWidget {
  final int roomId;
  final WebSocketConnection connection;
  final List<PopupMenuChoice> choices = [
    PopupMenuChoice(0, Icon(Icons.add), "Add question"),
    PopupMenuChoice(1, Icon(Icons.save), "Save changes")
  ];

  QuizManagement({@required this.connection, @required this.roomId});

  @override
  _QuizManagementState createState() => _QuizManagementState();
}

class _QuizManagementState extends State<QuizManagement> {
  Quiz quiz;

  @override
  void initState() {
    widget.connection.addListener('get_quiz', (msg) {
      if (msg['status'] == 'success') {
        setState(() {
          quiz = Quiz.fromJSON(msg['quiz']);
          print(quiz.questions);
        });
      } else {
        print(msg['error']);
      }
    });
    widget.connection.addListener('update_quiz', (msg) {
      if (msg['status'] == 'success') {
        showToast('Quiz updated successfully!');
      } else {
        print(msg['error']);
      }
    });
    refreshQuiz();
    super.initState();
  }

  Future<void> refreshQuiz() async {
    widget.connection.sendMessage('get_quiz', widget.roomId);
  }

  Future<QuizQuestion> showEditQuestionDialog(BuildContext context,
      {int questionId}) {
    QuizQuestion question =
        questionId == null ? null : quiz.questions[questionId];
    return showDialog(
        context: context,
        builder: (context) {
          TextEditingController _statementController =
              new TextEditingController(
                  text: question == null ? "" : question.statement);
          List<TextEditingController> _choiceControllers =
              new List<TextEditingController>(4);
          for (int i = 0; i < _choiceControllers.length; i++) {
            _choiceControllers[i] = new TextEditingController(
                text: question == null ? "" : question.choices[i]);
          }
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                  decoration: BoxDecoration(
//                    gradient: LinearGradient(
//                        colors: [Color(0xFF2B3443), Color(0xFF5C677B)]),
                    color: customBlue[1],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 18.0, 12.0, 18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Edit Question',
                              style:
                                  TextStyle(fontSize: 25, fontFamily: 'Acme'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(children: [
                            SizedBox(
                              height: 15,
                            ),
                            CustomTextField(
                              controller: _statementController,
                              hintText: 'Question statement',
                              icon: Icons.text_fields,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            CustomTextField(
                              controller: _choiceControllers[0],
                              hintText: 'Choice 1',
                              icon: Icons.lightbulb_outline,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            CustomTextField(
                              controller: _choiceControllers[1],
                              hintText: 'Choice 2',
                              icon: Icons.lightbulb_outline,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            CustomTextField(
                              controller: _choiceControllers[2],
                              hintText: 'Choice 3',
                              icon: Icons.lightbulb_outline,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            CustomTextField(
                              controller: _choiceControllers[3],
                              hintText: 'Choice 4',
                              icon: Icons.lightbulb_outline,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomButton(
                                    text: 'Save',
                                    onPressed: () {
                                      bool isEmpty = false;
                                      if (_statementController.text == "") {
                                        showToast("Statement cannot be empty");
                                        isEmpty = true;
                                      } else {
                                        for (TextEditingController _controller
                                            in _choiceControllers) {
                                          if (_controller.text == "") {
                                            showToast(
                                                "Choices cannot be empty");
                                            isEmpty = true;
                                            break;
                                          }
                                        }
                                      }
                                      if (!isEmpty) {
                                        Navigator.pop(
                                            context,
                                            QuizQuestion(
                                                statement:
                                                    _statementController.text,
                                                imageUrl: null,
                                                choices: _choiceControllers
                                                    .map((e) => e.text)
                                                    .toList()));
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  CustomButton(
                                    text: 'Cancel',
                                    onPressed: () {
                                      Navigator.pop(context, null);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return quiz == null
        ? Container()
        : CustomScaffold(
            title: Text(
              'Edit Quiz',
              style: TextStyle(fontFamily: 'Acme', fontSize: 30),
            ),
            body: Expanded(
              child: RefreshIndicator(
                onRefresh: refreshQuiz,
                child: ListView.builder(
                  itemCount: quiz.questions.length,
                  itemBuilder: (context, index) {
                    QuizQuestion question = quiz.questions[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 6.0,
                        bottom: 6.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: customBlue[2],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              // edit question Dialog
                              QuizQuestion question =
                                  await showEditQuestionDialog(context,
                                      questionId: index);
                              if (question != null) {
                                setState(() {
                                  quiz.questions[index] = question;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    4.0, 10.0, 4.0, 10.0),
                                child: ListTile(
//                            leading: RoomIcon(
//                              room: rooms[index],
//                              width: 50,
//                              height: 50,
//                              fontSize: 30,
//                            ),
//                            leading: Container(
//                              width: 50,
//                              decoration: BoxDecoration(
//                                borderRadius: BorderRadius.circular(15.0),
//                                color: customBlue[1],
//                              ),
//                              child: Padding(
//                                padding: const EdgeInsets.all(8.0),
//                                child: Center(
//                                  child: Text(
//                                    '${rooms[index].name.substring(0, 1).toUpperCase()}',
//                                    style: TextStyle(
//                                      fontSize: 30,
//                                      fontFamily: 'Acme',
//                                      color: customBlue[0],
////                                      fontWeight: FontWeight.bold,
//                                    ),
//                                  ),
//                                ),
//                              ),
//                            ),
                                  title: Text(
                                    question.statement.length > 20
                                        ? question.statement.substring(0, 20) +
                                            "..."
                                        : question.statement,
                                    style: TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Image: ${question.imageUrl}',
                                    style: TextStyle(
                                      color: limeYellow,
                                    ),
                                  ),
                                  trailing: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          quiz.questions.removeAt(index);
                                        });
                                      },
                                      child: Icon(Icons.close)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            fab: true,
            choices: widget.choices,
            onSelected: (choice) async {
              switch (choice.choiceId) {
                case 0:
                  QuizQuestion question =
                      await showEditQuestionDialog(context, questionId: null);
                  if (question != null) {
                    setState(() {
                      quiz.questions.add(question);
                    });
                  }
                  //            refreshRoomList();
                  break;
                case 1:
                  // TODO: save changes
                  print(quiz);
                  widget.connection.sendMessage('update_quiz', quiz);
                  refreshQuiz();
                  break;
              }
            },
          );
  }
}