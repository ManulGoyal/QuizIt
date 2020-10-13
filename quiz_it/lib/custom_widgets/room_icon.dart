import 'package:flutter/material.dart';
import 'package:quizit/utilities.dart';

class RoomIcon extends StatelessWidget {
  final Room room;
  final double height, width, fontSize;
  RoomIcon({@required this.room, this.height, this.width, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: customBlue[1],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '${room.name.substring(0, 1).toUpperCase()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Acme',
              color: customBlue[0],
//                                      fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
