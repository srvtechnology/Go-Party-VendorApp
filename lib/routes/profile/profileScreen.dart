import 'package:flutter/material.dart';
import 'package:utsavlife/core/utils/UIColor.dart';
import 'package:utsavlife/routes/profile/bankTab.dart';
import 'package:utsavlife/routes/profile/documentTab.dart';
import 'package:utsavlife/routes/profile/officeTab.dart';
import 'package:utsavlife/routes/profile/personalTab.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [

            Container(
              color: UIColor.screen_bg, // Background color for the tab bar
              child: TabBar(

                indicatorColor: UIColor.theme_color, // Indicator color
                labelColor: UIColor.theme_color, // Selected tab text color
                unselectedLabelColor:
                    UIColor.hint_text_color, // Unselected tab text color
                tabs: [
                  Tab(text: 'Personal'),
                  Tab(text: 'Office'),
                  Tab(text: 'Bank'),
                  Tab(text: 'Doc'),
                ],
              ),
            ),
            Expanded(
                child: TabBarView(children: [
              Personaltab(),
              officeTab(),
              BankTab(),
              DocumentTab()
            ]))
          ],
        ),
      ),
    );
  }
}
