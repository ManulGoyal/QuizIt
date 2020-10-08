import 'package:flutter/material.dart';

/* A custom TextField used in the ConnectionPage */
class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  CustomTextField(
      {@required this.hintText,
      @required this.icon,
      @required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        this.icon,
        color: Colors.white,
        size: 30,
      ),
      title: TextField(
        controller: this.controller,
        decoration: new InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(20.0),
            ),
            borderSide: BorderSide(
              color: Colors.white,
              width: 1,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(20.0),
            ),
            borderSide: BorderSide(
              color: Colors.white,
              width: 1,
            ),
          ),
          filled: true,
          hintStyle: TextStyle(color: Colors.grey[400]),
          hintText: this.hintText,
        ),
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
