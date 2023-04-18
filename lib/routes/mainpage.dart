import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/networkProvider.dart';
import 'package:utsavlife/routes/homepage.dart';
import 'package:utsavlife/routes/signIn.dart';

import 'errorScreen.dart';

class MainPage extends StatelessWidget {
  static const routeName ="mainpage";
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context,state,child){
              if(state.isOnline){
                return child!;
              }
              return errorScreenRoute(icon: Icons.wifi,message: "Seems like you are offline.Please connect to a network",hasAppbar: false,);
      },
      child: Consumer<AuthProvider>(builder: (context,auth,child){
        if(auth.authState==AuthState.LoggedIn){
          return Homepage();
        }
        else if(auth.authState == AuthState.Waiting){
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }
        else{
          return SignIn();
        }
      }),
    );
  }
}
