import 'package:flutter/material.dart';
import 'package:splash_view/source/source.dart';
import 'package:utsavlife/routes/signIn.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = "splash";
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashView(
      duration:const Duration(seconds: 2),
      logo: Image.asset("assets/images/logo/logo-nav.png"),
      done: Done(
        const SignIn()
      ),
    );
  }
}