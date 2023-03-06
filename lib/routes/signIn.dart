
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/homepage.dart';
import 'package:utsavlife/routes/signUp.dart';

class SignIn extends StatefulWidget {
  static const routeName ="signin";
  const SignIn({ Key? key }) : super(key: key);

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
          return Scaffold(
            body: Container(
              child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                      height: 20.h,
                      width: 40.w,
                      child: Image.asset("assets/images/logo/logo-nav.png"),
                    ),
                    if(state.authState==AuthState.Error)
                      Text("Incorrect username or password",style: TextStyle(color: Colors.red),),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Text("Welcome", style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall,),
                    ), Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: const Text("Provide your login details below"),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputField("Email", _email),
                            InputField("Password", _password),
                          ],
                        )),
                    SignInButton(context),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      alignment: Alignment.bottomRight,
                      child: TextButton(onPressed: () {
                        Navigator.pushNamed(context, SignUp.routeName);
                      }, child: const Text("New? Sign up")),
                    )
                  ],)
              ),
            ),
          );
        }
      ),
    );
  }
  Widget SignInButton(BuildContext context){
    return OutlinedButton(
      onPressed: (){
        if(_formKey.currentState!.validate()){
          context.read<AuthProvider>().login(_email.text, _password.text);
        }
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
      ),
      child: const Text("Sign In"),
    );
  }
  Widget InputField(String title,TextEditingController controller){
      return Container(
        margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: title,border: const OutlineInputBorder()),
          validator: (value){
            if(value==null || value.isEmpty){
              return "Please enter ${title.toLowerCase()}";
            }
          },
        ),
      );
  }
}