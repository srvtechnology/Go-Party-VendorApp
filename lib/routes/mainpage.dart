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
    return ListenableProvider(
        create: (_)=>RegisterProvider(),
    child:Consumer<NetworkProvider>(
      builder: (context,state,child){
              if(state.isOnline){
                return child!;
              }
              return errorScreenRoute(icon: Icons.wifi,message: "Seems like you are offline.Please connect to a network",hasAppbar: false,);
      },
      child: Consumer2<AuthProvider,RegisterProvider>(builder: (context,auth,registerState,child) {
        CustomLogger.debug(registerState.registerProgress);
        if (auth.authState == AuthState.LoggedIn) {
          if (auth.user?.userStatus == UserApprovalStatus.unverified) {
            if (registerState.registerProgress != RegisterProgress.completed && registerState.registerProgress != RegisterProgress.one) {
              return SignUp(dialogShow: true,);
            }
            return errorScreenRoute(
                icon: Icons.account_box,
                message: "Thank you for registering. Your account has not yet been verified by the admin. Check again later");
          }
          return Homepage();
        }
        else if (auth.authState == AuthState.Waiting) {
          return LoadingWidget(willRedirect: true,);
        }
        return SignIn();
      }
    )
    )
    );
  }
}
