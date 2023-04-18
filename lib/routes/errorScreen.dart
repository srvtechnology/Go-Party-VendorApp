import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class errorScreenRoute extends StatelessWidget {
  IconData icon;
  String message;
  bool hasAppbar=true;
  errorScreenRoute({Key? key,required this.icon,required this.message,this.hasAppbar=true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppbar?AppBar():null,
      body:Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Icon(icon,size: 100,color: Theme.of(context).primaryColorDark,),
            ),
            Divider(height: 5.h,color: Colors.transparent,),
            Text(message,textAlign: TextAlign.center,style: Theme.of(context).textTheme.headlineSmall,)
          ],
        ),
      )
    );
  }
}
