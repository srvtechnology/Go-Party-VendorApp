
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/signUp.dart';
import '../core/components/inputFields.dart';
import 'otpPage.dart';

class SignIn extends StatefulWidget {
  static const routeName ="signin";
  bool showPopup;
  SignIn({ Key? key ,this.showPopup=false}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _email=TextEditingController();
  final TextEditingController _password=TextEditingController();
  final _formKey = GlobalKey<FormState>();
    @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AuthProvider>(
        builder:(context,state,child) {
          if(state.authState==AuthState.Waiting){
            return Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
          return Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/login-background.jpg"),
                    fit: BoxFit.fitHeight
                  )
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: DefaultTextStyle(
                  style: TextStyle(color: Colors.white),
                  child: Container(
                    child: SingleChildScrollView(
                        child: Column(children: [
                          Container(
                            height: 20.h,
                            width: 40.w,
                            child: Image.asset("assets/images/logo/logo.png"),
                          ),
                          if(state.authState==AuthState.Error)
                            Text("Incorrect username or password",style: TextStyle(color: Colors.red),),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Text("Welcome !", style: Theme
                                .of(context)
                                .textTheme
                                .headlineSmall!.copyWith(color: Colors.white),),
                          ),
                          SizedBox(height: 40,),
                          Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  InputField(title:"Email", controller:_email),
                                  InputField(title: "Password", controller:_password,obscureText: true,isPassword: true),
                                ],
                              )),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Expanded(child: SignInButton(context)),
                              ],
                            ),
                          ),
                          Center(
                            child: Text("OR"),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            alignment: Alignment.bottomRight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () {
                                    Navigator.pushNamed(context, SignUp.routeName);
                                  }, child: const Text("Register for new vendor",style: TextStyle(color: Colors.white),)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                            alignment: Alignment.center,
                            child: TextButton(onPressed: () {
                              Navigator.pushNamed(context, OtpPageRoute.routeName);
                            }, child: const Text(" Forgot your password? Click here",style: TextStyle(color: Colors.white),)),
                          ),
                        ],)
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
  Widget SignInButton(BuildContext context){
    return ElevatedButton(
      onPressed: (){
        if(_formKey.currentState!.validate()){
          context.read<AuthProvider>().login(_email.text, _password.text);
        }
      },
      child: const Text("Sign In"),
    );
  }
}

