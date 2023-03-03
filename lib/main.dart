import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:utsavlife/routes/homepage.dart';
import 'package:utsavlife/routes/signIn.dart';

void main() {
  runApp(
    DevicePreview(
      builder: (context)
      =>
      MaterialApp(
        useInheritedMediaQuery: true,
        initialRoute: SignIn.routeName,
        routes: {
            SignIn.routeName:(context)=>const SignIn(),
            Homepage.routeName:(context)=>const Homepage(),
        },
      )
      )
  );
}
