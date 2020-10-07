import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/* A utility function to conveniently show toasts. */
void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.black,
      fontSize: 16.0);
}
