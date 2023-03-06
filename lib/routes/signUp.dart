import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'homepage.dart';
class SignUp extends StatefulWidget {
  static const routeName = "signup";
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _email=TextEditingController();
  final TextEditingController _name=TextEditingController();
  final TextEditingController _company=TextEditingController();
  final TextEditingController _password=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: SingleChildScrollView(
              child:Column(children: [
                SizedBox(
                  height: 20.h,
                  width: 40.w,
                  child: Image.asset("assets/images/logo/logo-nav.png"),
                ),
                Container(
                  alignment: Alignment.center,
                  margin:const EdgeInsets.symmetric(vertical: 10),
                  child: Text("Welcome",style: Theme.of(context).textTheme.headlineSmall,),
                ),Container(
                  alignment: Alignment.center,
                  margin:const EdgeInsets.symmetric(vertical: 10),
                  child:const Text("Provide your details below"),
                ),
                InputField("Full Name", _name),
                InputField("Company", _company),
                InputField("Email", _email),
                InputField("Password", _password),
                SignUpButton(context),

              ],)
          ),
        ),
      ),
    );
  }
  Widget SignUpButton(BuildContext context){
    return OutlinedButton(
      onPressed: (){
        Navigator.pushNamed(context, Homepage.routeName);
      },
      style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
      ),
      child: const Text("Sign Up"),
    );
  }
  Widget InputField(String title,TextEditingController controller){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: title,border: const OutlineInputBorder()),
      ),
    );
  }
}
