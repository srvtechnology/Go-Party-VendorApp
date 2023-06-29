import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/components/loading.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/RegisterProvider.dart';
import 'package:utsavlife/core/provider/networkProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/routes/homepage.dart';
import 'package:utsavlife/routes/signIn.dart';
import 'package:utsavlife/routes/signUp.dart';

import 'errorScreen.dart';

class MainPage extends StatelessWidget {
  static const routeName ="mainpage";
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    return ListenableProvider(
        create: (_)=>RegisterProvider(),
    child:Consumer<NetworkProvider>(
      builder: (context,state,child){
              if(state.isOnline){
                return child!;
              }
              return errorScreenRoute(icon: Icons.wifi,message: "Seems like you are offline.Please connect to a network",hasAppbar: false,);
      },
      child: Consumer<AuthProvider>(builder: (context,auth,child) {
         if (auth.authState == AuthState.Waiting){
          return LoadingWidget(willRedirect: true,);
        }
         if (auth.authState == AuthState.LoggedIn) {
          if (auth.user?.userStatus == UserApprovalStatus.unverified) {
            if(auth.user!.progress != RegisterProgress.one && auth.user!.progress != RegisterProgress.completed)
              {
                return SignUp();
              }
            return errorScreenRoute(
                icon: Icons.account_box,
                message: "Your account is under verification process, please wait for 24-48 working hours.");
          }
          return Homepage();
        }
        else if (auth.authState == AuthState.Waiting) {
          return LoadingWidget(willRedirect: true,);
        }
        bool arg = args!=null?args as bool:false;
        return SignIn(showPopup: arg,);
      }
    )
    )
    );
  }
}
