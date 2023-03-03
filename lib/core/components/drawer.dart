import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({ Key? key }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:SingleChildScrollView(child: Column(children: const[
        Text("Option"),
        Divider(height: 5,),
        Text("Option"),
        Divider(height: 5,),
        Text("Option"),
        Divider(height: 5,)
      ],)),
    );
  }
}