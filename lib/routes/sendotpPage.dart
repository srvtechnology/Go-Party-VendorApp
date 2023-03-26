import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/routes/otpPage.dart';

class sendOtpPageRoute extends StatefulWidget {
  static const routeName = "sendOTP";
  const sendOtpPageRoute({Key? key}) : super(key: key);

  @override
  State<sendOtpPageRoute> createState() => _sendOtpPageRouteState();
}

class _sendOtpPageRouteState extends State<sendOtpPageRoute> {
  @override
  Widget build(BuildContext context) {
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
              decoration: InputDecoration(labelText: "Email",border: const OutlineInputBorder()),
            ),
            Container(
              margin: EdgeInsets.all(40),
              child: OutlinedButton(onPressed: (){
                Navigator.pushReplacementNamed(context, OtpPageRoute.routeName);
              }, child: Text("Next")),
            )
          ],
        ),
      ),
    );
  }
}
