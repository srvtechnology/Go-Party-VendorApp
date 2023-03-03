import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({ Key? key }) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _index=0;
  int get index => _index ;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _index,
      onTap: (index){
        setState(() {
          _index=index;
        });
      },
      items: const[
        BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile"),
        BottomNavigationBarItem(icon: Icon(Icons.arrow_circle_down),label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.arrow_circle_down),label: "Orders"),
    ]);
  }
}