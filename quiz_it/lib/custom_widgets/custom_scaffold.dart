import 'package:quizit/utilities.dart';
import 'package:flutter/material.dart';

class PopupMenuChoice {
  final int choiceId;
  final Icon icon;
  final String text;

  PopupMenuChoice(this.choiceId, this.icon, this.text);
}

class CustomScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;
  final bool fab;
  final List<PopupMenuChoice> choices;
  final Function(PopupMenuChoice) onSelected;

  CustomScaffold(
      {@required this.title,
      @required this.body,
      this.fab = false,
      this.choices,
      this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customBlue[3],
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                    child: Center(
                      child: title,
                    ),
                  ),
                  body,
                ],
              ),
            ),
            fab
                ? Positioned(
                    right: 30,
                    bottom: 30,
                    child: PopupMenuButton<PopupMenuChoice>(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.menu,
                          color: Colors.black,
                        ),
                      ),
                      elevation: 3.2,
//                initialValue: "maunl",

                      onSelected: (choice) {
                        onSelected(choice);
                      },
                      itemBuilder: (BuildContext context) {
                        return choices.map((choice) {
                          return PopupMenuItem<PopupMenuChoice>(
                            value: choice,
                            child: ListTile(
                              leading: choice.icon,
                              title: Text(
                                choice.text,
                                style: TextStyle(fontFamily: 'Prompt'),
                              ),
                            ),
                          );
                        }).toList();
                      },
                      offset: Offset(0, -150),
                    ),
                  )
                : Container(
                    height: 0,
                    width: 0,
                  ),
          ],
        ),
      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.add),
//        onPressed: () {
//          showCreateRoomDialog(context);
//        },
//      ),
    );
  }
}
