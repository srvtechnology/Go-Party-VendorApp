import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';

class errorScreenRoute extends StatefulWidget {
  IconData icon;
  String message;
  bool hasAppbar;
  bool showPopUp;
  errorScreenRoute({Key? key,required this.icon,required this.message,this.hasAppbar=true,this.showPopUp=false}) : super(key: key);

  @override
  State<errorScreenRoute> createState() => _errorScreenRouteState();
}

class _errorScreenRouteState extends State<errorScreenRoute> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppbar?AppBar(
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
              child: Icon(widget.icon,size: 100,color: Theme.of(context).primaryColorDark,),
            ),
            Divider(height: 5.h,color: Colors.transparent,),
            Text(widget.message,textAlign: TextAlign.center,style: Theme.of(context).textTheme.headlineSmall,)
          ],
        ),
      )
    );
  }
}
