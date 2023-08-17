

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:utsavlife/core/components/loading.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/routes/homepage.dart';
import 'package:utsavlife/routes/mainpage.dart';
import 'package:utsavlife/routes/notifications.dart';
import 'package:utsavlife/routes/otpPage.dart';
import 'package:utsavlife/routes/servicelist.dart';
import 'package:utsavlife/routes/settingsPage.dart';
import 'package:utsavlife/routes/signIn.dart';
import 'package:utsavlife/routes/signUp.dart';
import 'package:utsavlife/routes/singleServiceAdd.dart';
import 'package:utsavlife/routes/splash.dart';
import 'package:utsavlife/routes/wallet.dart';
import 'core/provider/networkProvider.dart';
import 'core/provider/showcaseProvider.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context)
      =>
      ResponsiveSizer(
        builder:(context,orientation,type)
        =>
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_)=>AuthProvider()),
            ChangeNotifierProvider(create: (_)=>NetworkProvider()),
            ChangeNotifierProvider(create: (_)=>ShowCaseProvider()),
          ],
          child: Consumer<ShowCaseProvider>(
            builder:(context,state,child){

              if(state.isLoading){
                return LoadingWidget();
              }
              return ShowCaseWidget(
              enableShowcase: state.show,
              onFinish: (){
                CustomLogger.debug("Finished");
                state.setState();
              },
              builder: Builder(
                builder: (context) {
                  return MaterialApp(
                    theme: ThemeData(
                        primaryColor:const Color(0xff0264a5),
                        appBarTheme: const AppBarTheme(color: Color(0xff0264a5),
                        ),),
                    useInheritedMediaQuery: true,
                    initialRoute: SplashScreen.routeName,
                    routes: {
                        SplashScreen.routeName:(context) =>SafeArea(child: const SplashScreen()),
                        SignIn.routeName:(context)=>SafeArea(child: SignIn()),
                        SignUp.routeName:(context)=>SafeArea(child: SignUp()),
                        MainPage.routeName:(context)=>const SafeArea(child: MainPage()),
                        NotificationPage.routeName:(context)=>const SafeArea(child: NotificationPage()),
                        Homepage.routeName:(context)=> SafeArea(child: Homepage()),
                        OtpPageRoute.routeName:(context)=>const SafeArea(child: OtpPageRoute()),
                        serviceListRoute.routeName:(context)=> const SafeArea(child: serviceListRoute()),
                        AddServiceRoute.routeName:(context)=> SafeArea(child: AddServiceRoute()),
                        SettingsPage.routeName:(context)=> SafeArea(child: SettingsPage()),
                        AccountPage.routeName:(context)=>SafeArea(child: AccountPage()),
                        WalletPage.routeName:(context)=>SafeArea(child: WalletPage()),
                    },
                  );
                }
              ),
            );
            }
          ),
        ),
      )
      )
  );
}


