import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/customBox.dart';
import 'package:utsavlife/core/components/gradientButton.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/UIColor.dart';
import 'package:utsavlife/routes/signup/signUp.dart';
import '../core/components/inputFields.dart';
import 'otpPage.dart';

const EdgeInsets textInputPadding =
    EdgeInsets.symmetric(vertical: 8, horizontal: 0);

class SignIn extends StatefulWidget {
  static const routeName = "signin";
  bool showPopup;

  SignIn({Key? key, this.showPopup = false}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AuthProvider>(builder: (context, state, child) {
        if (state.authState == AuthState.Waiting) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          backgroundColor: UIColor.screen_bg,
          body: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                height: 20.h,
                width: 40.w,
                child: Image.asset("assets/images/logo/logo.png"),
              ),
              CustomMaterialBox(listOfChildren: [
                if (state.authState == AuthState.Error)
                  Text(
                    "Incorrect username or password",
                    style: TextStyle(color: Colors.red),
                  ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    "Welcome !",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: UIColor.black_text_color),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InputField(
                          title: "Email",
                          controller: _email,
                          edgeInsets: textInputPadding,
                        ),
                        InputField(
                            title: "Password",
                            controller: _password,
                            obscureText: true,
                            isPassword: true,
                            edgeInsets: textInputPadding),
                      ],
                    )),
                customDivider(),
                SignInButton(context),
                customDivider(),
                Center(
                  child: Text("OR"),
                ),
                customDivider(),
                GradientButton(
                    buttonInsideMaterialBox: true,
                    colors: [
                      UIColor.error_color,
                      UIColor.error_color,
                    ],
                    text: "Register for new vendor",
                    onPressed: () {
                      Navigator.pushNamed(context, SignUp.routeName);
                    }),
                customDivider(),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  alignment: Alignment.center,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, OtpPageRoute.routeName);
                      },
                      child: const Text(
                        " Forgot your password? Click here",
                        style: TextStyle(color: UIColor.black_text_color),
                      )),
                ),
              ]),
            ],
          )),
        );

        /*Stack(
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
              ,
            ],
          );*/
      }),
    );
  }

  Widget SignInButton(BuildContext context) {
    return GradientButton(
        buttonInsideMaterialBox: true,
        text: "Sign In",
        onPressed: () => {
              if (_formKey.currentState!.validate())
                {
                  context
                      .read<AuthProvider>()
                      .login(_email.text, _password.text)
                }
            });
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: UIColor.theme_color),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<AuthProvider>().login(_email.text, _password.text);
        }
      },
      child: DefaultTextStyle(
          style: TextStyle(color: Colors.white), child: const Text("Sign In")),
    );
  }
}

Widget customDivider() {
  return SizedBox(
    height: 20,
  );
}
