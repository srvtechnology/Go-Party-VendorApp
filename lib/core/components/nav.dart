import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
typedef Ontap=Function(int index);
class CustomBottomNavBar extends StatefulWidget {
  Ontap ontap;
  int index;
  CustomBottomNavBar({ Key? key ,required this.index,required this.ontap}) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.index,
      onTap: widget.ontap,
      items: const[
        BottomNavigationBarItem(icon: Icon(Icons.arrow_circle_down),label: "Orders"),
        BottomNavigationBarItem(icon: Icon(Icons.arrow_circle_down),label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile"),
    ]);
  }
}