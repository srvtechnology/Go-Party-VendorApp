import 'dart:math';

import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/otpProvider.dart';

class OtpPageRoute extends StatefulWidget {
  static const routeName = "otp";
  const OtpPageRoute({Key? key}) : super(key: key);

  @override
  State<OtpPageRoute> createState() => _OtpPageRouteState();
}

class _OtpPageRouteState extends State<OtpPageRoute> {
  TextEditingController _p1 = new TextEditingController();
  TextEditingController _p2 = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (_)=>OtpProvider(),
      builder:(context,child)=> Consumer<OtpProvider>(
        builder:(context,state,child){
          if (state.isLoading == true){
            return Container(color: Theme.of(context).scaffoldBackgroundColor,child: CircularProgressIndicator(),alignment: Alignment.center,);
          }
          if(state.userId == null){
            return EmailScaffold(state);
          }
          if(state.otp != null){
            return ChangePassScaffold(state);
          }
          return OtpScaffold(state);
        }
      ),
    );
  }
  Widget EmailScaffold(OtpProvider state){
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        height: 100.h,
        width: 100.w,
        padding: EdgeInsets.all(20),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 50),
                child: Text("Enter your email.",style: Theme.of(context).textTheme.headlineSmall,)),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email",border: const OutlineInputBorder()),
            ),
            Container(
              margin: EdgeInsets.all(40),
              child: OutlinedButton(onPressed: (){
                if(_emailController.text.contains("@") && _emailController.text.length>3) {
                  state.get_otp(_emailController.text);
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid email")));
                }
              }, child: Text("Next")),
            )
          ],
        ),
      ),
    );
  }
  Widget OtpScaffold(OtpProvider state){
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        height: 100.h,
        width: 100.w,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Text("Please enter OTP sent to your mail",style: TextStyle(fontSize: 18.sp),),
            ),
            Container(
              height: 60.h,
              alignment: Alignment.center,
              child: OTPTextField(
                length: 5,
                width: 80.w,
                onChanged: (pin){
                  logger.d(pin);
                },
                onCompleted: (pin){
                  state.otp = pin ;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showError(String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  void handleChange(OtpProvider state)async{
    if(_p1.text != _p2.text){
        showError("Both passwords do not match");
    }
    else if(_p1.text.length<6){
      showError("Password must be at least 6 characters long.");
    }
    else{
      await state.setPassword(_p1.text);
      if(state.passwordChanged==true){
        showError("Password successfully changed");
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      else{
        showError("Wrong OTP entered");
      }
      }
    }
  Widget ChangePassScaffold(OtpProvider state){
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: 100.h,
        width: 100.w,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: 20,vertical: 40),
              child: Text("Reset password",style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 20.sp),),
            ),
            InputField("New password", _p1),
            InputField("Confirm password", _p2),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: OutlinedButton(onPressed: () {
                handleChange(state);
              }, child: Text("Proceed")),
            )
          ],
        ),
      ),
    );
  }

  Widget InputField(String title, TextEditingController controller,
      {bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
            labelText: title, border: const OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter ${title.toLowerCase()}";
          }
        },
      ),
    );
  }
}

