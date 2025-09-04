import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NotificationPage extends StatefulWidget {
  static const routeName="notifications";
  const NotificationPage({Key? key}) : super(key: key);
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
              SingleNotification(),
            ],
          ),
        ),
    );
  }
  Widget SingleNotification(){
    return Container(
      height: 8.h,
      child: Row(
        children:const [
          Expanded(child: Icon(Icons.notifications)),
          Expanded(flex:5,child: Text("Your package has arrived. ")),
        ],
      ),
    );
  }
}
