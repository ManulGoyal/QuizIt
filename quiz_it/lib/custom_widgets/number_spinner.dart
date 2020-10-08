import 'package:flutter/material.dart';

class NumberSpinner extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final Function onChange;

  NumberSpinner(
      {@required this.value,
      @required this.onChange,
      @required this.minValue,
      @required this.maxValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            child: RawMaterialButton(
              onPressed: () {
                onChange(value <= minValue ? minValue : value - 1);
              },
//            elevation: 2.0,
              fillColor: Colors.white,
              child: Icon(
                Icons.remove,
                color: Color(0xFF181E2C),
//              size: 35.0,
              ),
//            padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(fontSize: 15),
          ),
          Container(
            width: 50,
            child: RawMaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                onChange(value >= maxValue ? maxValue : value + 1);
              },
//            elevation: 2.0,
              fillColor: Colors.white,
              child: Icon(
                Icons.add,
                color: Color(0xFF181E2C),
//              size: 35.0,
              ),
//            padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
