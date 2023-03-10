

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/homepage.dart';
import 'package:utsavlife/routes/mainpage.dart';
import 'package:utsavlife/routes/notifications.dart';
import 'package:utsavlife/routes/signIn.dart';
import 'package:utsavlife/routes/signUp.dart';
import 'package:utsavlife/routes/splash.dart';

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
          ],
          child: MaterialApp(
            theme: ThemeData(primaryColor:const Color(0xff2596be),appBarTheme: const AppBarTheme(color: Color(0xff0264a5))),
            useInheritedMediaQuery: true,
            initialRoute: SplashScreen.routeName,
            routes: {
                SplashScreen.routeName:(context) =>const SplashScreen(),
                SignIn.routeName:(context)=>const SignIn(),
                SignUp.routeName:(context)=>const SignUp(),
                MainPage.routeName:(context)=>const MainPage(),
                NotificationPage.routeName:(context)=>const NotificationPage(),
                Homepage.routeName:(context)=>const Homepage(),
            },
          ),
        ),
      )
      )
  );
}


