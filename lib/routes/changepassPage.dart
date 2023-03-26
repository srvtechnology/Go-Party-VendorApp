
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChangePasswordRoute extends StatefulWidget {
  const ChangePasswordRoute({Key? key}) : super(key: key);

  @override
  State<ChangePasswordRoute> createState() => _ChangePasswordRouteState();
}

class _ChangePasswordRouteState extends State<ChangePasswordRoute> {
  TextEditingController _p1 = new TextEditingController();
  TextEditingController _p2 = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: 100.h,
        width: 100.w,
        child: Column(
          children: [
            InputField("New password", _p1),
            InputField("Confirm password", _p2),
            OutlinedButton(onPressed: () {}, child: Text("Proceed"))
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
