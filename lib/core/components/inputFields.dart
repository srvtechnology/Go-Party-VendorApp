import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  TextEditingController controller;
  String title;
  Icon? leading;
  bool obscureText=false,isPassword=false;
  InputField({Key? key,
    required this.controller,
    required this.title,
    this.obscureText=false,
    this.isPassword = false,
    this.leading
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        obscureText: widget.obscureText,
        controller: widget.controller,
        decoration: InputDecoration(
            prefixIcon: widget.leading,
            prefixIconColor: Colors.white,
            label:Text(widget.title,style: TextStyle(color: Colors.white),),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.white,
                width: 1.0,
              ),
            ),suffixIcon: widget.isPassword?
        IconButton(
          onPressed: (){
            setState(() {
              widget.obscureText=!widget.obscureText;
            });
          },icon: Icon(Icons.remove_red_eye_outlined,color: Colors.white,),
        )
            :
        null),
        validator: (value){
          if(value==null || value.isEmpty){
            return "Please enter ${widget.title.toLowerCase()}";
          }
        },
      ),
    );
  }
}
