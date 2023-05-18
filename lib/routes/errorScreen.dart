import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';

class errorScreenRoute extends StatelessWidget {
  IconData icon;
  String message;
  bool hasAppbar;
  errorScreenRoute({Key? key,required this.icon,required this.message,this.hasAppbar=true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hasAppbar?AppBar(
        actions: [
          IconButton(onPressed: (){
            context.read<AuthProvider>().logout();
          }, icon: Icon(Icons.logout)),
        ],
      ):AppBar(automaticallyImplyLeading: false,),
      body:Container(
        padding: EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topCenter,
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
