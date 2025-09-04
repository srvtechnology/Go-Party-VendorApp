import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:splash_view/source/source.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/mainpage.dart';
import 'package:utsavlife/routes/signIn.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = "splash";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    return SplashView(
      duration:const Duration(seconds: 2),
      logo: SizedBox(
        height: 20.h,
        width: 40.w,
        child: Image.asset("assets/images/logo/logo.png"),
      ),
      done: Done(
        const MainPage()
      ),
    );
  }
}