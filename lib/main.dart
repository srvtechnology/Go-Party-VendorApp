

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/CompleteRegistration.dart';
import 'package:utsavlife/routes/errorScreen.dart';
import 'package:utsavlife/routes/homepage.dart';
import 'package:utsavlife/routes/mainpage.dart';
import 'package:utsavlife/routes/notifications.dart';
import 'package:utsavlife/routes/otpPage.dart';
import 'package:utsavlife/routes/servicelist.dart';
import 'package:utsavlife/routes/signIn.dart';
import 'package:utsavlife/routes/signUp.dart';
import 'package:utsavlife/routes/singleServiceAdd.dart';
import 'package:utsavlife/routes/splash.dart';

import 'core/provider/networkProvider.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context)
      =>
      ResponsiveSizer(
        builder:(context,orientation,type)
        =>
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_)=>AuthProvider()),
            ChangeNotifierProvider(create: (_)=>NetworkProvider()),
          ],
          child: MaterialApp(
            theme: ThemeData(
                primaryColor:const Color(0xff2596be),
                appBarTheme: const AppBarTheme(color: Color(0xff0264a5),
                ),),
            useInheritedMediaQuery: true,
            initialRoute: SplashScreen.routeName,
            routes: {
                SplashScreen.routeName:(context) =>SafeArea(child: const SplashScreen()),
                SignIn.routeName:(context)=>SafeArea(child: SignIn()),
                SignUp.routeName:(context)=>SafeArea(child: const SignUp()),
                MainPage.routeName:(context)=>const SafeArea(child: MainPage()),
                NotificationPage.routeName:(context)=>const SafeArea(child: NotificationPage()),
                Homepage.routeName:(context)=> SafeArea(child: Homepage()),
                OtpPageRoute.routeName:(context)=>const SafeArea(child: OtpPageRoute()),
                serviceListRoute.routeName:(context)=> const SafeArea(child: serviceListRoute()),
                AddServiceRoute.routeName:(context)=> SafeArea(child: AddServiceRoute()),
                CompleteRegistrationRoute.routeName:(context)=>SafeArea(child: CompleteRegistrationRoute())
            },
          ),
        ),
      )
      )
  );
}


