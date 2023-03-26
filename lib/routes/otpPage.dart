import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OtpPageRoute extends StatefulWidget {
  static const routeName = "otp";
  const OtpPageRoute({Key? key}) : super(key: key);

  @override
  State<OtpPageRoute> createState() => _OtpPageRouteState();
}

class _OtpPageRouteState extends State<OtpPageRoute> {
  @override
  Widget build(BuildContext context) {
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
                length: 6,
                width: 80.w,
                onCompleted: (pin){},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
