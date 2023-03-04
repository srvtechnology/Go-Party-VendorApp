import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/routes/homepage.dart';
import 'package:utsavlife/routes/signIn.dart';
import 'package:utsavlife/routes/splash.dart';

void main() {
  runApp(
    DevicePreview(
      builder: (context)
      =>
      ResponsiveSizer(
        builder:(context,orientation,type)=>MaterialApp(
          theme: ThemeData(primaryColor: Colors.blueAccent),
          useInheritedMediaQuery: true,
          initialRoute: SplashScreen.routeName,
          routes: {
              SplashScreen.routeName:(context) =>const SplashScreen(),
              SignIn.routeName:(context)=>const SignIn(),
              Homepage.routeName:(context)=>const Homepage(),
          },
        ),
      )
      )
  );
}
