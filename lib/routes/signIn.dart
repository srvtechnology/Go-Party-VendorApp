
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/routes/homepage.dart';

class SignIn extends StatefulWidget {
  static const routeName ="signin";
  const SignIn({ Key? key }) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _email=TextEditingController();
  final TextEditingController _password=TextEditingController();
  
    @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
            child: SingleChildScrollView(
              child:Column(children: [
                    InputField("Email", _email),
                    InputField("Password", _password),
                    SignInButton(context)
              ],) 
              ),
          ),
      ),
    );
  }
  Widget SignInButton(BuildContext context){
    return TextButton(onPressed: (){
        Navigator.pushNamed(context, Homepage.routeName);
    }, child:const Text("Sign In"));
  }
  Widget InputField(String title,TextEditingController controller){
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
        ),
      );
  }
}