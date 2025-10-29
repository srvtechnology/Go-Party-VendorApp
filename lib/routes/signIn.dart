import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/signUp.dart';
import '../core/components/inputFields.dart';
import '../core/utils/TramsAndConditionsCheckBox.dart';
import 'otpPage.dart';

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
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, state, child) {
      return Scaffold(
        body: Container(
          height: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8.h),
                  SizedBox(
                    child: Image.asset(
                      'assets/images/logo/logo.png',
                      width: 60.w,
                      height: 12.h,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Vendor Login ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15.0), // Rounded corners
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align items to the start
                        children: [
                          if (state.authState == AuthState.Error)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Incorrect username or password",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.email, color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.grey),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password should be at least 6 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, OtpPageRoute.routeName);
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const SizedBox(height: 16.0),

                          SizedBox(
                            width: double.infinity,
                            child: SignInButton(context),
                          ),

                          // or
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              )
                              //
                            ],
                          ),
                          // const SizedBox(height: 16.0),
                          // Textbutton new to utsav life
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  "New to Utsavlife?",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // create your
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, SignUp.routeName);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                              ),
                              child: const Text(
                                'Create Your Account',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // Center(
                          //   child: RichText(
                          //     text: TextSpan(
                          //       text: 'Are you an agent? ',
                          //       style: const TextStyle(
                          //         color: Colors.black,
                          //         fontSize: 14,
                          //       ),
                          //       children: <TextSpan>[
                          //         TextSpan(
                          //           recognizer: TapGestureRecognizer()
                          //             ..onTap = () {
                          //               SignInButton(context);
                          //             },
                          //           text: 'Sign in',
                          //           style: const TextStyle(
                          //             color: Colors.blue,
                          //             fontSize: 16,
                          //           ),
                          //         ),
                          //         const TextSpan(
                          //           text: ' or ',
                          //           style: TextStyle(
                          //             color: Colors.black,
                          //             fontSize: 16,
                          //           ),
                          //         ),
                          //         TextSpan(
                          //           recognizer: TapGestureRecognizer()
                          //             ..onTap = () {
                          //
                          //             },
                          //           text: 'Sign up',
                          //           style: const TextStyle(
                          //             color: Colors.blue,
                          //             fontSize: 16,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TramsAndConditionsCheckBox(
                    value: false,
                    onChanged: (value) {},
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            // Navigator.pushNamed(
                            //     context, TermsAndCondition.routeName);
                          },
                          child: const Text(
                            "Terms & Condition",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      TextButton(
                          onPressed: () {
                            // Navigator.pushNamed(
                            //     context, PrivacyPolicy.routeName);
                          },
                          child: const Text(
                            "Privacy & policy",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '© 2023 - UTSAVLIFE. All Rights Reserved.',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Consumer<AuthProvider>(
  //       builder: (context, state, child) {
  //         if (state.authState == AuthState.Waiting) {
  //           return Container(
  //             color: Colors.white,
  //             alignment: Alignment.center,
  //             child: const CircularProgressIndicator(),
  //           );
  //         }
  //
  //         return Stack(
  //           children: [
  //             BackdropFilter(
  //               filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
  //               child: Container(
  //                 height: double.infinity,
  //                 width: double.infinity,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             Scaffold(
  //               backgroundColor: Colors.transparent,
  //               body: DefaultTextStyle(
  //                 style: const TextStyle(color: Colors.white),
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     children: [
  //                       SizedBox(height: 4.h),
  //                       SizedBox(
  //                         height: 20.h,
  //                         width: 40.w,
  //                         child: Image.asset("assets/images/logo/logo.png"),
  //                       ),
  //                       const SizedBox(height: 16),
  //                       Text(
  //                         "Welcome!",
  //                         style: Theme.of(context)
  //                             .textTheme
  //                             .headlineSmall!
  //                             .copyWith(color: Colors.black),
  //                       ),
  //                       const SizedBox(height: 20),
  //
  //                       /// 👇 Wrap the login form in a Card
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Card(
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(15.0),
  //                           ),
  //                           elevation: 15,
  //                           child: Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 25, vertical: 20),
  //                             child: Column(
  //                               children: [
  //                                 if (state.authState == AuthState.Error)
  //                                   const Text(
  //                                     "Incorrect username or password",
  //                                     style: TextStyle(color: Colors.red),
  //                                   ),
  //                                 const SizedBox(height: 16),
  //
  //                                 Form(
  //                                   key: _formKey,
  //                                   child: Column(
  //                                     children: [
  //                                       InputField(
  //                                         title: "Email",
  //                                         controller: _email,
  //                                       ),
  //                                       const SizedBox(height: 16),
  //                                       InputField(
  //                                         title: "Password",
  //                                         controller: _password,
  //                                         obscureText: true,
  //                                         isPassword: true,
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 const SizedBox(height: 20),
  //
  //                                 /// Sign In button
  //                                 SizedBox(
  //                                   width: double.infinity,
  //                                   child: SignInButton(context),
  //                                 ),
  //                                 const SizedBox(height: 16),
  //
  //                                 const Text(
  //                                   "OR",
  //                                   style: TextStyle(color: Colors.black),
  //                                 ),
  //                                 const SizedBox(height: 16),
  //
  //                                 /// Register button
  //                                 SizedBox(
  //                                   width: double.infinity,
  //                                   child: ElevatedButton(
  //                                     style: ElevatedButton.styleFrom(
  //                                       backgroundColor: Colors.red,
  //                                     ),
  //                                     onPressed: () {
  //                                       Navigator.pushNamed(
  //                                           context, SignUp.routeName);
  //                                     },
  //                                     child: const Text(
  //                                       "Register for new vendor",
  //                                       style: TextStyle(color: Colors.white),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 const SizedBox(height: 16),
  //
  //                                 /// Forgot password
  //                                 TextButton(
  //                                   onPressed: () {
  //                                     Navigator.pushNamed(
  //                                         context, OtpPageRoute.routeName);
  //                                   },
  //                                   child: const Text(
  //                                     "Forgot your password? Click here",
  //                                     style: TextStyle(color: Colors.blue),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget SignInButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4, // optional shadow
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<AuthProvider>().login(_email.text, _password.text);
        }
      },
      child: const Text(
        "Sign In",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    )
    ;
  }
}
