import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/UIColor.dart';

class InputField extends StatefulWidget {
  TextEditingController controller;
  String title;
  Icon? leading;
  bool obscureText = false, isPassword = false;
  final EdgeInsets? edgeInsets;

  InputField(
      {Key? key,
      required this.controller,
      required this.title,
      this.obscureText = false,
      this.isPassword = false,
      this.leading,
      this.edgeInsets = null})
      : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.edgeInsets,
      child: TextFormField(
        style: TextStyle(color: UIColor.black_text_color),
        obscureText: widget.obscureText,
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
            prefixIcon: widget.leading,
            prefixIconColor: UIColor.black_text_color,
            label: Text(
              widget.title,
              style: TextStyle(color: UIColor.hint_text_color),
            ),
            /*         errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.red,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: UIColor.black_text_color,
                width: 1.0,
              ),
            ),*/
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        widget.obscureText = !widget.obscureText;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye_outlined,
                      color: UIColor.prefix_icon_tint,
                    ),
                  )
                : null),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter ${widget.title.toLowerCase()}";
          }
        },
      ),
    );
  }
}
