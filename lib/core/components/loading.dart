import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/mainpage.dart';

class LoadingWidget extends StatefulWidget {
  bool willRedirect;
  LoadingWidget({Key? key,this.willRedirect=false}) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  Timer? t;
  @override
  void initState() {
    super.initState();
    if(widget.willRedirect){
      t = Timer(Duration(seconds: 15), () {
        Provider.of<AuthProvider>(context,listen: false).logout();
        Navigator.pushReplacementNamed(context, MainPage.routeName);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
  @override
  void dispose() {
    super.dispose();
    t?.cancel();
  }
}
