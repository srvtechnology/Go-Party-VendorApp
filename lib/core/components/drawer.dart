import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/mainpage.dart';
import 'package:utsavlife/routes/signIn.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({ Key? key }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:ListView(
    // Important: Remove any padding from the ListView.
    padding: EdgeInsets.zero,
    children: [
      ListTile(
        title: const Text('Item 1'),
        onTap: () {
        },
      ),
      ListTile(
        title: const Text('Logout'),
        onTap: () {
          Provider.of<AuthProvider>(context,listen: false).logout();
          Navigator.pushReplacementNamed(context, MainPage.routeName);
        },
      ),
    ],
      ),
    );
  }
}