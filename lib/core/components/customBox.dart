import 'package:flutter/material.dart';

import '../utils/UIColor.dart';

class CustomMaterialBox extends StatelessWidget {
  List<Widget> listOfChildren;
  String? heading;

  CustomMaterialBox({super.key, required this.listOfChildren, this.heading = null});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(heading!=null)
        Container(
          margin: EdgeInsets.only(bottom: 15, left: 15),
          child: Text(heading!,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700
          ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              shadowColor: UIColor.theme_color,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: Column(
                  children: listOfChildren,
                ),
              )),
        ),
      ],
    );
  }
}
