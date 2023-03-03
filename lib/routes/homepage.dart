import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:utsavlife/core/components/drawer.dart';
import 'package:utsavlife/core/components/nav.dart';

class Homepage extends StatefulWidget {
  static const routeName = "home";
  const Homepage({ Key? key }) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(),
        drawer: const CustomDrawer(),
        bottomNavigationBar:const CustomBottomNavBar(),
    );
  }
}