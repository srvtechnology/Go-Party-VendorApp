import 'dart:math';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
// import 'package:csc_picker/csc_picker.dart'; // Temporarily disabled due to compatibility issues
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/components/loading.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/RegisterProvider.dart';
import 'package:utsavlife/core/provider/mapProvider.dart';
import 'package:utsavlife/core/repo/auth.dart';
import 'package:utsavlife/core/repo/maps.dart';
import 'package:utsavlife/core/utils/geolocator.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/core/utils/textformatters.dart';
import 'package:utsavlife/routes/mainpage.dart';
import 'package:utsavlife/routes/singleServiceAdd.dart';

import '../core/components/inputFields.dart';
import '../core/models/dropdown.dart';
import '../core/provider/ServiceProvider.dart';
import '../core/utils/TramsAndConditionsCheckBox.dart';
import '../core/utils/stepprogressindicator.dart';
import 'errorScreen.dart';
import 'otpPage.dart';

class SignUp extends StatefulWidget {
  final bool dialogShow;
  static const routeName = "signup";

  const SignUp({Key? key, this.dialogShow = false}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Widget? _cachedChild;
  RegisterProgress? _cachedProgress;

  @override
  void initState() {
    super.initState();

    if (widget.dialogShow) {
      Future.delayed(const Duration(milliseconds: 200), () {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Please complete your registration to proceed"),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Selector so only progress changes trigger rebuild
    return Selector<AuthProvider, RegisterProgress>(
      selector: (_, auth) => auth.user?.progress ?? RegisterProgress.one,
      builder: (context, progress, _) {
        Widget newChild;

        // Choose which step to show based on progress
        switch (progress) {
          case RegisterProgress.two:
            newChild = const SignUp2();
            break;
          case RegisterProgress.three:
            newChild = const SignUpIntermediate();
            break;
          case RegisterProgress.four:
            newChild = const SignUp3();
            break;
          case RegisterProgress.five:
            newChild =  SignUp4();
            break;
          case RegisterProgress.six:
            newChild=TermsAndConditionsPage();
            break;

          default:
            newChild = const SignUp1();
        }

        // Only update cached screen if progress actually changed
        if (_cachedProgress != progress) {
          _cachedProgress = progress;
          _cachedChild = newChild;
          debugPrint("Screen changed → $progress");
        }
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                StepProgressIndicatorWidget(
                  currentStep: progress.index + 1,
                  totalSteps: 6,
                ),
                const SizedBox(height: 20),
                // Keep current step widget cached and animated
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _cachedChild ?? newChild,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



class SignUp1 extends StatefulWidget {
  const SignUp1({Key? key}) : super(key: key);

  @override
  State<SignUp1> createState() => _SignUp1State();
}

class _SignUp1State extends State<SignUp1> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobileNo = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedCountry = "", selectedCity = "", selectedState = "";
  late List<TextEditingController> _controllers;
  bool showLocationList = false;
bool _obscureText=false;
  bool isLoading = false;
  late Future _getLocation;
  List<String> dataKeys = [
    "name",
    "email",
    "password",
    "mobile",
    "address_address",
    "distance_cover",
    "address_latitude",
    "address_longitude"
  ];

  @override
  void initState() {
    _controllers = [_name, _email, _mobileNo, _password, _address, _area];
    _getLocation = _initCountryStateCity();
    super.initState();
  }

  Future _initCountryStateCity() async {
    var data = await getCountryCityState();
    setState(() {
      selectedCountry = data["country"];
      selectedState = data["state"];
      selectedCity = data["city"];
      _address.text = selectedCity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLocation,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return SafeArea(
          child: ListenableProvider(
            create: (_) => MapProvider(),
            child: Consumer2<MapProvider, AuthProvider>(
              builder: (context, mapState, registerState, child) =>
                  GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: Scaffold(
                      backgroundColor: Colors.white, // 👈 White background
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        leading: IconButton(
                          color: Colors.black,
                          onPressed: () {
                            registerState.logout();
                            Navigator.pushReplacementNamed(
                                context, MainPage.routeName);
                          },
                          icon: const Icon(Icons.arrow_back_ios),
                        ),
                        elevation: 0,
                        title: const Text(
                          "Basic Information",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        iconTheme: const IconThemeData(color: Colors.black),
                      ),
                      body: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  child: Image.asset(
                                    'assets/images/logo/logo.png',
                                    width: 160,
                                    height: 112,
                                  ),
                                ),
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        // Logo
                                        const SizedBox(height: 10),
                                        Text(
                                          "Welcome",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(color: Colors.black),
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: _name,
                                          decoration: const InputDecoration(
                                            labelText: 'Full Name',
                                            labelStyle: TextStyle(color: Colors.grey),
                                            prefixIcon: Icon(Icons.supervised_user_circle_rounded, color: Colors.grey),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter your name';
                                            }

                                            return null;
                                          },
                                        ),
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
                                        const SizedBox(height: 12),
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

                                        const SizedBox(height: 12),
                                        // Phone input
                                        IntlPhoneField(
                                          initialCountryCode: "IN",
                                          showCountryFlag: true,
                                          dropdownIcon: const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: "Phone Number",
                                            labelStyle: TextStyle(color: Colors.grey),
                                            prefixIcon: Icon(Icons.phone, color: Colors.grey),

                                            // ✅ Underline style borders
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                            ),
                                            errorBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red, width: 1.0),
                                            ),
                                            focusedErrorBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red, width: 2.0),
                                            ),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          dropdownTextStyle: const TextStyle(color: Colors.black),
                                          validator: (text) {
                                            if (text == null || text.completeNumber.isEmpty) {
                                              return "Please enter your phone number";
                                            }
                                            if (text.completeNumber.length < 10 ||
                                                text.completeNumber.length > 15) {
                                              return "Please enter a valid number";
                                            }
                                            return null;
                                          },
                                          onChanged: (number) {
                                            _mobileNo.text = number.completeNumber;
                                          },
                                        ),


                                        const SizedBox(height: 20),

                                        // Info box
                                        // Container(
                                        //   padding: const EdgeInsets.all(16),
                                        //   decoration: BoxDecoration(
                                        //     borderRadius: BorderRadius.circular(10),
                                        //     border: Border.all(
                                        //         color: Colors.black, width: 1),
                                        //     color: Colors.grey[100],
                                        //   ),
                                        //   child: const Text(
                                        //     "Location picker temporarily disabled",
                                        //     style: TextStyle(color: Colors.black),
                                        //   ),
                                        // ),

                                        const SizedBox(height: 20),

                                        // Submit button
                                        if (isLoading)
                                          const CircularProgressIndicator()
                                        else
                                          SignUpButton(context, mapState, registerState),
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
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }


  Future<void> submit(AuthProvider registerState, MapProvider mapState) async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        "name": _name.text.toString(),
        "email": _email.text,
        "password": _password.text,
        "mobile": _mobileNo.text,
        "address_address": _address.text,
        "distance_cover": 0,
        "address_latitude": 0,
        "address_longitude": 0,
        "vendor_reg_part": 2
      };
      CustomLogger.debug(data);
      var response = await signUpMain(data);
      var responseData = response.data;

      if (responseData["result"]["code"] == "200") {
        final String regOtp = responseData["result"]["user"]["reg_otp"] ?? "";
        final String uid =
            responseData["result"]["user"]["id"].toString() ?? "";

        showOtpVerificationDialog(
          context: context,
          otpToDisplay: regOtp,
          onSubmit: (otp) async {
            print('Submitted OTP: $otp');
            var result = await registerState.submitOtp(registerState, uid, otp);
            print("$result");

            if (data != null &&
                (data["success"] == true || data["result"]?["code"] == "200")) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Success"),
                  content: Text(data["message"] ??
                      "You have successfully completed your registration.Your account is under verification process, please wait for 24-48 working hours."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );

              if (data != null &&
                  (data["success"] == true ||
                      data["result"]?["code"] == "200")) {
                showMessageDialog(context,
                    "You have successfully completed your registration.Your account is under verification process, please wait for 24-48 working hours.");
              }
            }

            // errorScreenRoute(
            //     showPopUp: true,
            //     icon: Icons.account_box,
            //     message: "You have successfully completed your registration.Your account is under verification process, please wait for 24-48 working hours.");
            registerState.setRegisterProgress(RegisterProgress.two);
          },
          onResendOtp: () async {
            print('Resend OTP clicked');
            var result = await registerState.resendOtp(uid);
            print("$result");
          },
        );
      } else {
        final errorMsg =
            responseData["result"]["message"] ?? "Something went wrong";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showOtpVerificationDialog({
    required BuildContext context,
    required void Function(String otp) onSubmit,
    required VoidCallback onResendOtp,
    required String otpToDisplay,
  }) async {
    final TextEditingController _otpController = TextEditingController();
    bool isResending = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Verify OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your OTP: $otpToDisplay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      counterText: '',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: isResending
                        ? null
                        : () async {
                            setState(() {
                              isResending = true;
                            });

                            await Future.delayed(Duration(seconds: 1));
                            onResendOtp();

                            setState(() {
                              isResending = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('OTP resent')),
                            );
                          },
                    child: isResending
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Resend OTP'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final otp = _otpController.text.trim();
                    if (otp.length == 6) {
                      Navigator.of(dialogContext).pop();
                      onSubmit(otp);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please enter a valid 6-digit OTP')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget SignUpButton(
      BuildContext context, MapProvider mapState, AuthProvider registerState) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  setState(() {
                    isLoading = true;
                  });
                  await submit(registerState, mapState);
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  CustomLogger.error(e);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text("Save and Continue"),
            ),
          ),
        ],
      ),
    );
  }

  Widget CustomInputField(String title, TextEditingController controller,
      {Icon leading = const Icon(
        Icons.person,
        color: Colors.black,
      ),
      bool hide = false,
      bool autocomplete = true,
      MapProvider? state,
      validatePhone = false}) {
    if (validatePhone) {
      if (!controller.text.startsWith("+91"))
        controller.text = "+91" + controller.text;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      child: TextFormField(
          style: TextStyle(color: Colors.black),
          keyboardType:
              validatePhone ? TextInputType.phone : TextInputType.text,
          obscureText: hide,
          controller: controller,
          validator: (text) {
            if (text?.length == 0) return "Required field";
            if (validatePhone) {
              if (text != null && (text.length < 10 || text.length > 15)) {
                return "Please enter a valid phone number";
              }
            }
          },
          onChanged: (text) {
            if (state != null) {
              setState(() {
                showLocationList = true;
              });
              state.getLocations(text);
              CustomLogger.debug(state.locations);
            }
          },
          decoration: InputDecoration(
            prefixIcon: leading,
            label: Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
            ),
          )),
    );
  }
}

class SignUp2 extends StatefulWidget {
  const SignUp2({Key? key}) : super(key: key);

  @override
  State<SignUp2> createState() => _SignUp2State();
}
class _SignUp2State extends State<SignUp2> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController _pancard = TextEditingController();
  final TextEditingController _kycNo = TextEditingController();
  final TextEditingController _kycType = TextEditingController();
  final TextEditingController _houseNo = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _pinCode = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _country = TextEditingController();

  bool showLocationFields = false;

  late DropDownField selectedKyc;

  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar", value: "AD"),
    DropDownField(title: "Voter Id", value: "VO"),
    DropDownField(title: "Passport", value: "PA"),
    DropDownField(title: "Driving License", value: "DL"),
    DropDownField(title: "Other Govt. Id", value: "OT"),
  ];

  @override
  void initState() {
    super.initState();
    selectedKyc = kyctypes.first;

    // 🔹 Listen for pincode input and fetch location automatically
    _pinCode.addListener(() {
      final text = _pinCode.text.trim();
      if (text.length == 6) {
        _getLocationfromPinCode(text);
      } else {
        setState(() => showLocationFields = false);
      }
    });
  }

  bool isNumeric(String s) => double.tryParse(s) != null;

  @override
  void dispose() {
    _pancard.dispose();
    _kycNo.dispose();
    _kycType.dispose();
    _houseNo.dispose();
    _area.dispose();
    _landmark.dispose();
    _pinCode.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> submit(AuthProvider state) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1)); // simulate API delay
    setState(() => isLoading = false);
    state.setRegisterProgress(RegisterProgress.three);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data saved successfully!")),
    );
  }

  Widget SignUpButton(BuildContext context, AuthProvider state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => state.setRegisterProgress(RegisterProgress.three),
          child: const Text("Skip"),
        ),
        const SizedBox(width: 30),
        ElevatedButton(
          onPressed: () => submit(state),
          child: const Text("Save & Continue"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, state, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  state.logout();
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
              title: const Text(
                "Personal Information",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                        elevation: 4,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // PAN NUMBER FIELD
                                TextFormField(
                                  controller: _pancard,
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    labelText: 'Pan Number (optional)',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    prefixIcon: Icon(Icons.numbers, color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey, width: 2),
                                    ),
                                  ),
                                  validator: (text) {
                                    if (text == null || text.isEmpty) return null;
                                    if (text.length != 10 ||
                                        (isNumeric(text.substring(0, 5))) ||
                                        (!isNumeric(text.substring(5, 9))) ||
                                        (isNumeric(text.substring(9, 10)))) {
                                      return "Please enter a valid Pan Number";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // KYC TYPE DROPDOWN
                                DropdownButtonFormField<DropDownField>(
                                  value: selectedKyc,
                                  decoration: const InputDecoration(
                                    labelText: 'KYC Type (optional)',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey, width: 2),
                                    ),
                                  ),
                                  items: kyctypes
                                      .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.title),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedKyc = value!;
                                      _kycType.text = value.value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 16),

                                // KYC NUMBER FIELD
                                TextFormField(
                                  controller: _kycNo,
                                  decoration: InputDecoration(
                                    labelText: "${selectedKyc.title} Number (optional)",
                                    labelStyle: const TextStyle(color: Colors.grey),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                    ),
                                  ),
                                  validator: (text) {
                                    if (text == null || text.isEmpty) return null;
                                    if (selectedKyc.value == "AD" && text.length != 12) {
                                      return "Please enter a valid number";
                                    }
                                    if (text.length < 12) {
                                      return "Please enter a valid number";
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // ADDRESS FIELDS
                                TextFormField(
                                  controller: _houseNo,
                                  decoration: const InputDecoration(
                                    labelText: "Flat / House / Building Number",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    prefixIcon:
                                    Icon(Icons.home_filled, color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey, width: 2),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _area,
                                  decoration: const InputDecoration(
                                    labelText: "Street / Sector / Village / Area",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    prefixIcon:
                                    Icon(Icons.location_on, color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey, width: 2),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _landmark,
                                  decoration: const InputDecoration(
                                    labelText: "Landmark",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    prefixIcon: Icon(Icons.place, color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey, width: 2),
                                    ),
                                  ),
                                ),

                                // 🔹 PINCODE FIELD
                                TextFormField(
                                  controller: _pinCode,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Pin code",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    prefixIcon:
                                    Icon(Icons.pin_drop, color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.grey, width: 2.0),
                                    ),
                                  ),
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return "Required Field";
                                    }
                                    if (text.length != 6) {
                                      return "Please enter a 6 digit valid pincode";
                                    }
                                    return null;
                                  },
                                ),

                                // 🔹 Conditionally show City/State/Country
                                if (showLocationFields) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _city,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "City",
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _state,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "State",
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _country,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: "Country",
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 20),

                                if (isLoading)
                                  const CircularProgressIndicator()
                                else
                                  SignUpButton(context, state),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ✅ Logo
                      Positioned(
                        top: -50,
                        child: Image.asset(
                          'assets/images/logo/logo.png',
                          width: 160,
                          height: 112,
                        ),
                      ),
                    ],
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
        );
      },
    );
  }

  Future<void> _getLocationfromPinCode(String pincode) async {
    var data = await getCountryStateCityfromZip(pincode);
    setState(() {
      _country.text = data["country"] ?? "";
      _state.text = data["state"] ?? "";
      _city.text = data["city"] ?? "";
      showLocationFields = true;
    });
  }
}

class DropDownField {
  final String title;
  final String value;
  DropDownField({required this.title, required this.value});
}

class SignUp3 extends StatefulWidget {
  const SignUp3({Key? key}) : super(key: key);

  @override
  State<SignUp3> createState() => _SignUp3State();
}

class _SignUp3State extends State<SignUp3> {
  final _formKey = GlobalKey<FormState>();

  final List<DropDownField> accountTypes = [
    DropDownField(title: "Current Account", value: "current"),
    DropDownField(title: "Savings Account", value: "saving"),
    DropDownField(title: "Salary Account", value: "salary"),
    DropDownField(title: "Fixed Deposit Account", value: "fixed"),
    DropDownField(title: "Recurring Deposit Account", value: "recurring"),
    DropDownField(title: "NRI Account", value: "nri"),
  ];

  final TextEditingController _bankName = TextEditingController();
  final TextEditingController _accountType = TextEditingController();
  final TextEditingController _accountNo = TextEditingController();
  final TextEditingController _accountNoConfirm = TextEditingController();
  final TextEditingController _ifscNo = TextEditingController();
  final TextEditingController _holderName = TextEditingController();
  final TextEditingController _branchName = TextEditingController();

  late DropDownField selectedAccount;
  String? passbookPath;
  bool isLoading = false;
  bool isDataLoaded = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    selectedAccount = accountTypes[0];
    _loadCacheData();
  }

  Future<void> _loadCacheData() async {
    final auth = context.read<AuthProvider>();
    final bankDetails = auth.user?.bankDetails;
    if (bankDetails != null) {
      selectedAccount = accountTypes.firstWhere(
            (e) => e.value == bankDetails.accountType,
        orElse: () => accountTypes[0],
      );
      _accountType.text = selectedAccount.value;
      _bankName.text = bankDetails.bankName ?? "";
      _accountNo.text = bankDetails.accountNumber ?? "";
      _ifscNo.text = bankDetails.ifscNumber ?? "";
      _holderName.text = bankDetails.holderName ?? "";
      _branchName.text = bankDetails.branchName ?? "";
    }
    setState(() {
      isDataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          "Bank Details",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final state = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Image.asset(
            "assets/images/logo/logo.png",
            height: 100,
            width: 150,
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InputField(
                      "Bank Name", _bankName,
                      leading: const Icon(Icons.account_balance, color: Colors.black)),
                  const SizedBox(height: 16),

                  // Account Type Dropdown
                 // add this to your State class

            Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.black),
                labelText: "Account Type",
                labelStyle: TextStyle(color: Colors.black),
                border: UnderlineInputBorder(),
              ),
              child: ExpansionTile(
                title: Text(selectedAccount.title),
                trailing: const Icon(Icons.arrow_drop_down, color: Colors.black),
                initiallyExpanded: _isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isExpanded = expanded;
                  });
                },
                children: accountTypes.map((e) {
                  return ListTile(
                    title: Text(e.title),
                    onTap: () {
                      setState(() {
                        selectedAccount = e;
                        _accountType.text = e.value;
                        _isExpanded = false; // 🔥 collapse after selection
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),


          InputField("Account Number", _accountNo, accountConfirm: true),
                  InputField("Re-Enter Account Number", _accountNoConfirm,
                      accountConfirm: true),
                  InputField("IFSC Code", _ifscNo),
                  InputField("Holder Name", _holderName),
                  InputField("Branch Name", _branchName,
                      leading: const Icon(Icons.home_outlined, color: Colors.black)),

                  const SizedBox(height: 16),

                  // Passbook Upload
                  Row(
                    children: [
                      Expanded(
                        child: passbookPath == null
                            ? const Text(
                          "Cancelled Checkbook / Passbook Front page",
                          style: TextStyle(color: Colors.black),
                        )
                            : Container(
                          height: 80,
                          width: 80,
                          alignment: Alignment.centerLeft,
                          child: Image.file(File(passbookPath!)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () async {
                          final file = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (file != null) {
                            setState(() => passbookPath = file.path);
                          }
                        },
                        child: Text(passbookPath == null ? "Choose" : "Change"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  isLoading
                      ? const CircularProgressIndicator()
                      : SignUpButton(context, state),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20.0),
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
    );
  }

  Widget SignUpButton(BuildContext context, AuthProvider state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => state.setRegisterProgress(RegisterProgress.three),
            child: const Text("Skip"),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              try {
                await submit(state);
              } catch (e) {
                setState(() => isLoading = false);
                CustomLogger.error(e);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Save and Continue"),
          ),
        ),
      ],
    );
  }

  Widget InputField(String title, TextEditingController controller,
      {Icon leading = const Icon(Icons.person, color: Colors.black),
        bool hide = false,
        bool accountConfirm = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      child: TextFormField(
        keyboardType:
        accountConfirm ? TextInputType.number : TextInputType.text,
        obscureText: hide,
        controller: controller,
        validator: (text) {
          if (text?.isEmpty ?? true) return "Required field";
          if (accountConfirm) {
            if (_accountNo.text.length < 12 || _accountNo.text.length > 20) {
              return "Enter valid account number";
            }
            if (_accountNo.text != _accountNoConfirm.text) {
              return "Account numbers do not match";
            }
          }
          return null;
        },
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: leading,
          labelText: title,
          labelStyle: const TextStyle(color: Colors.black),
          border: const UnderlineInputBorder(),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
      ),
    );
  }

  Future<void> submit(AuthProvider state) async {
    if (_formKey.currentState!.validate()) {
      if (passbookPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Please upload a cancelled check or passbook front page.")),
        );
        return;
      }

      setState(() => isLoading = true);

      final data = {
        "bank_name": _bankName.text,
        "acc_no": _accountNo.text,
        "ifsc_no": _ifscNo.text,
        "holder_name": _holderName.text,
        "branch_name": _branchName.text,
        "acc_type": _accountType.text,
        "img1": await MultipartFile.fromFile(passbookPath!),
        "vendor_reg_part": 5,
      };

      await completeRegistration2(state, data);
      setState(() => isLoading = false);


      state.setRegisterProgress(RegisterProgress.four);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your data has been successfully recorded.")),
      );
    }
  }
}




class SignUp4 extends StatefulWidget {
  const SignUp4({Key? key}) : super(key: key);

  @override
  State<SignUp4> createState() => _SignUp4State();
}

class _SignUp4State extends State<SignUp4> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late Future _cache;
  String? panUrl, kyc, gst, vendor;
  bool prev = false;
  Map<String, String?> imgPath = {
    "Pan Card": null,
    "KYC": null,
    "GST": null,
    "Vendor": null
  };

  @override
  void initState() {
    super.initState();
    _cache = getDataFromCache();
  }

  Future getDataFromCache() {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    panUrl = auth.user!.panCardUrl;
    kyc = auth.user!.kycUrl;
    gst = auth.user!.gstUrl;
    vendor = auth.user!.vendorUrl;
    prev = true;
    return Future.value();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, state, child) {
      return FutureBuilder(
          future: _cache,
          builder: (context, snapshot) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  color: Colors.black,
                  onPressed: () {
                    state.setRegisterProgress(RegisterProgress.four);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                title: const Text(
                  "KYC Documents",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.black),
              ),
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Logo outside card
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Image.asset(
                          "assets/images/logo/logo.png",
                          height: 150,
                        ),
                      ),

                      // Card container
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // no rounded corners
                        ),
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Pan Card
                              FilePickerField(
                                title: "Pan Card (optional)",
                                filePath: imgPath["Pan Card"],
                                url: panUrl,
                                onPick: (path) {
                                  setState(() {
                                    imgPath["Pan Card"] = path;
                                    panUrl = null;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              // GST
                              FilePickerField(
                                title: "GST (optional)",
                                filePath: imgPath["GST"],
                                url: gst,
                                onPick: (path) {
                                  setState(() {
                                    imgPath["GST"] = path;
                                    gst = null;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              // KYC
                              FilePickerField(
                                title: "KYC (optional)",
                                filePath: imgPath["KYC"],
                                url: kyc,
                                onPick: (path) {
                                  setState(() {
                                    imgPath["KYC"] = path;
                                    kyc = null;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              // Vendor Picture
                              FilePickerField(
                                title: "Vendor Picture (optional)",
                                filePath: imgPath["Vendor"],
                                url: vendor,
                                onPick: (path) {
                                  setState(() {
                                    imgPath["Vendor"] = path;
                                    vendor = null;
                                  });
                                },
                              ),

                              const SizedBox(height: 30),

                              // Loading or SignUp Button
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : SignUpButton(context, state),
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
            );
          });
    });
  }

  /// A helper widget to show file/image picker in underline style
  Widget FilePickerField({
    required String title,
    String? filePath,
    String? url,
    required Function(String path) onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: filePath != null
                  ? Image.file(File(filePath))
                  : url != null
                  ? CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) =>
                const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                const Icon(Icons.file_copy, size: 60),
              )
                  : const Icon(Icons.file_copy, size: 60),
            ),
            ElevatedButton(
              onPressed: () async {
                XFile? file = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 80);
                if (file != null) {
                  int size = await file.length() ~/ 1024;
                  if (size > 2048) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Image too big. Please select below 2MB")),
                    );
                  } else {
                    onPick(file.path);
                  }
                }
              },
              child: Text(filePath == null ? "Choose File" : "Change"),
            ),
          ],
        ),
      ],
    );
  }


  Future<void> submit(AuthProvider state) async {
    Map<String, dynamic> data = {
      "vendor_reg_part": 6,
    };
    setState(() {
      isLoading = true;
    });
    data["img1"] = imgPath["Pan Card"] == null
        ? null
        : await MultipartFile.fromFile(imgPath["Pan Card"]!);
    data["img2"] = imgPath["KYC"] == null
        ? null
        : await MultipartFile.fromFile(imgPath["KYC"]!);
    data["img3"] = imgPath["Vendor"] == null
        ? null
        : await MultipartFile.fromFile(imgPath["Vendor"]!);
    data["img4"] = imgPath["GST"] == null
        ? null
        : await MultipartFile.fromFile(imgPath["GST"]!);
    CustomLogger.debug(data);
    await completeRegistration3(state, data);
    state.setRegisterProgress(RegisterProgress.six);
    setState(() {
      isLoading = false;
    });
  }

  Widget SignUpButton(BuildContext context, AuthProvider state) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                state.setRegisterProgress(RegisterProgress.six);
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              )),
              child: const Text("Skip"),
            ),
          ),
          const SizedBox(
            width: 40,
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await submit(state);
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  CustomLogger.error(e);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              )),
              child: const Text("Save and Continue"),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpIntermediate extends StatefulWidget {
  const SignUpIntermediate({Key? key}) : super(key: key);

  @override
  State<SignUpIntermediate> createState() => _SignUpIntermediateState();
}

class _SignUpIntermediateState extends State<SignUpIntermediate> {
  String serviceOption = "Select Service", serviceId = "";

  final _formKey = GlobalKey<FormState>();
  bool showLocationList = false;
  bool isLoading = false;
  TextEditingController _serviceDescription = TextEditingController();
  TextEditingController _materialDescription = TextEditingController();
  TextEditingController _officePinCode = TextEditingController();
  TextEditingController _officeNo = TextEditingController();
  TextEditingController _officePhone = TextEditingController();
  TextEditingController _officeArea = TextEditingController();
  TextEditingController _officeLandmark = TextEditingController();
  TextEditingController _officeCity = TextEditingController();
  TextEditingController _officeState = TextEditingController();
  TextEditingController _officeCountry = TextEditingController();
  TextEditingController _GST = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _driverName = TextEditingController();
  TextEditingController _driverMob = TextEditingController();
  TextEditingController _driverKycType = TextEditingController();
  TextEditingController _driverKycNo = TextEditingController();
  TextEditingController _driverLicense = TextEditingController();
  TextEditingController _driverpinCode = TextEditingController();
  TextEditingController _driverhouseNo = TextEditingController();
  TextEditingController _driverArea = TextEditingController();
  TextEditingController _driverLandmark = TextEditingController();
  TextEditingController _driverCity = TextEditingController();
  TextEditingController _driverState = TextEditingController();
  late DropDownField selectedKyc = DropDownField(title: "Aadhar", value: "AD");
  late Future _getCacheData;
  Future _getLocation = Future.value({});
  List<AddProductPhoto> productImages = [];
  String? driverImage, drivingLicenseImage;
  String? videoPath;
  List<String> dataKeys = [
    "category_id",
    "service_id",
    "service_desc",
    "material_desc",
    "office_pincode",
    "office_house_no",
    "office_area",
    "office_country",
    "office_landmark",
    "office_city",
    "office_state",
    "price",
    "driver_name",
    "driver_mobile_no",
    "driver_kyc_type",
    "dricer_kyc_no",
    "driver_licence_no",
    "driver_pincode",
    "driver_house_no",
    "driver_area",
    "driver_landmark",
    "driver_city",
    "driver_state",
    "gst_no"
  ];

  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar", value: "AD"),
    DropDownField(title: "Voter Id", value: "VO"),
    DropDownField(title: "Passport", value: "PA"),
    DropDownField(title: "Driving License", value: "DL"),
    DropDownField(title: "Other Govt. Id", value: "OT"),
  ];

  late Country selectedOfficeCountry;

  Future<void> getDataFromCache() async {
    AuthProvider auth = context.read<AuthProvider>();
    selectedOfficeCountry = Country(id: "101", name: "India");
    Map country = {"id": "101", "name": "India"};
    try {
      country = DefaultCountries.where(
          (element) => element["id"] == auth.user!.country?.id).first;
      if (!country.containsKey("id")) {
        country = {"id": "101", "name": "India"};
      }
    } catch (e) {}
    selectedOfficeCountry = Country(id: country["id"], name: country["name"]);
    _officePinCode.text = auth.user!.officeZip ?? "";
    _officeNo.text = auth.user!.officeNumber ?? "";
    _officePhone.text = auth.user!.officePhone ?? "";
    _officeArea.text = auth.user!.officeArea ?? "";
    _officeLandmark.text = auth.user!.officeLandmark ?? "";
    _officeCity.text = auth.user!.officeCity ?? "";
    _officeState.text = auth.user!.officeState ?? "";
    _officeCountry.text = selectedOfficeCountry.id;
    _GST.text = auth.user!.gstNumber ?? "";
    try {
      _driverKycType.text = kyctypes
              .firstWhere((element) =>
                  element.value == auth.user!.service?.driverDetails.kycType)
              .title ??
          "";
    } catch (e) {}
    _serviceDescription.text = auth.user!.service?.serviceDescription ?? "";
    _price.text = auth.user!.service?.price ?? "";
    _materialDescription.text = auth.user!.service?.materialDescription ?? "";
    _driverName.text = auth.user!.service?.driverDetails.name ?? "";
    _driverMob.text = auth.user!.service?.driverDetails.mobileNumber ?? "";
    _driverKycNo.text = auth.user!.service?.driverDetails.kycNumber ?? "";
    _driverpinCode.text = auth.user!.service?.driverDetails.pinCode ?? "";
    _driverhouseNo.text = auth.user!.service?.driverDetails.houseNumber ?? "";
    _driverArea.text = auth.user!.service?.driverDetails.area ?? "";
    _driverLandmark.text = auth.user!.service?.driverDetails.landmark ?? "";
    _driverCity.text = auth.user!.service?.driverDetails.landmark ?? "";
    _driverState.text = auth.user!.service?.driverDetails.state ?? "";
    _officePinCode.addListener(() {
      if (_officePinCode.text.length >= 6) {
        setState(() {
          _getLocation = _getLocationfromPinCode();
        });
      }
    });
  }

  Future _getLocationfromPinCode() async {
    var data = await getCountryStateCityfromZip(_officePinCode.text);
    setState(() {
      _officeCountry.text = data["country"]!;
      _officeState.text = data["state"]!;
      _officeCity.text = data["city"]!;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCacheData = getDataFromCache();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DropDownOptionProvider(auth: Provider.of<AuthProvider>(context)),
        ),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: Consumer2<DropDownOptionProvider, AuthProvider>(
        builder: (context, state, regState, child) {
          if (regState.isLoading || state.isLoading) {
            return LoadingWidget();
          }

          return FutureBuilder(
            future: Future.wait([_getCacheData, _getLocation]),
            builder: (context, snapshot) {
              return Consumer<MapProvider>(
                  builder: (context, mapState, child) => SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    leading: IconButton(
                      color: Colors.black,
                      onPressed: () {
                        regState.setRegisterProgress(RegisterProgress.two);
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    title: const Text(
                      "Office Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    iconTheme: const IconThemeData(color: Colors.black),
                  ),
                  body: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/images/logo/logo.png",
                                    height: 100,
                                  ),
                                  const SizedBox(height: 20),

                                  // GST Number - Underline style
                                  TextFormField(
                                    controller: _GST,
                                    decoration: const InputDecoration(
                                      labelText: "GST Number",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: UnderlineInputBorder(),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Phone Number - Underline style
                                  IntlPhoneField(
                                    initialCountryCode: "IN",
                                    showCountryFlag: false,
                                    dropdownIcon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey,
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      labelText: "Phone Number",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                                      ),
                                    ),
                                    validator: (text) {
                                      if (text == null || text.completeNumber.isEmpty) {
                                        return "Required field";
                                      }
                                      if (text.completeNumber.length < 12 || text.completeNumber.length > 15) {
                                        return "Please enter a valid number";
                                      }
                                      return null;
                                    },
                                    onChanged: (number) {
                                      _officePhone.text = number.completeNumber;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Address Fields - using InputField with underline
                                  InputField(
                                    "Flat / House / Building Number",
                                    _officeNo,
                                    underline: true,
                                    leading: const Icon(Icons.home_filled, color: Colors.grey),
                                  ),
                                  InputField(
                                    "Street / Sector / Village / Area",
                                    _officeArea,
                                    underline: true,
                                    leading: const Icon(Icons.location_on, color: Colors.grey),
                                  ),
                                  InputField(
                                    "Landmark",
                                    _officeLandmark,
                                    underline: true,
                                    leading: const Icon(Icons.place, color: Colors.grey),
                                  ),
                                  InputField(
                                    "Pin Code",
                                    _officePinCode,
                                    underline: true,
                                    isPin: true,
                                    leading: const Icon(Icons.pin_drop, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),

                                  // Location Info Box
                                  // Container(
                                  //   padding: const EdgeInsets.all(16),
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(10),
                                  //     border: Border.all(color: Colors.black, width: 1),
                                  //     color: Colors.grey[100],
                                  //   ),
                                  //   child: const Text(
                                  //     "Location picker temporarily disabled",
                                  //     style: TextStyle(color: Colors.black),
                                  //   ),
                                  // ),
                                  const SizedBox(height: 20),

                                  // Service Details
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Service Details",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  ExpansionTile(
                                    collapsedShape: const UnderlineInputBorder(
                                      borderSide: BorderSide(width: 1, color: Colors.grey),
                                    ),
                                    shape: const UnderlineInputBorder(
                                      borderSide: BorderSide(width: 1, color: Colors.grey),
                                    ),
                                    textColor: Colors.black,
                                    iconColor: Colors.black,
                                    title: Text(
                                      serviceOption,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                    children: state.options!.serviceOptions
                                        .map(
                                          (e) => ListTile(
                                        title: Text(
                                          e.service,
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            serviceOption = e.service;
                                            serviceId = e.id;
                                          });
                                        },
                                      ),
                                    )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 16),

                                  // Other InputFields - underline style
                                  InputField(
                                    "Service Description",
                                    _serviceDescription,
                                    underline: true,
                                    leading: const Icon(Icons.description, color: Colors.grey),
                                  ),
                                  InputField(
                                    "Material Description",
                                    _materialDescription,
                                    underline: true,
                                    leading: const Icon(Icons.description_outlined, color: Colors.grey),
                                  ),
                                  InputField(
                                    "Price",
                                    _price,
                                    underline: true,
                                    isPrice: true,
                                    leading: const Icon(Icons.currency_rupee, color: Colors.grey),
                                  ),

                                  const SizedBox(height: 16),

                                  // Photos & Video Sections remain same
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Product photos. Max 5",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (productImages.length >= 5) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Maximum 5 photos allowed")),
                                        );
                                        return;
                                      }
                                      List<XFile?> images = await ImagePicker().pickMultiImage();
                                      setState(() {
                                        for (var element in images) {
                                          if (productImages.length == 5) return;
                                          productImages.add(AddProductPhoto(
                                            filePath: element?.path,
                                            id: productImages.length,
                                            onDelete: (id) {
                                              setState(() {
                                                productImages.removeWhere((e) => e.id == id);
                                              });
                                            },
                                          ));
                                        }
                                      });
                                    },
                                    child: const Text("Add"),
                                  ),
                                  ...productImages,
                                  const SizedBox(height: 16),

                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Add a video",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                                        child: videoPath != null
                                            ? const Text("Video Selected")
                                            : const Text("No Video"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
                                          setState(() {
                                            videoPath = video?.path;
                                          });
                                        },
                                        child: const Text("Choose"),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),

                                  isLoading
                                      ? const CircularProgressIndicator()
                                      : CreateButton(context, regState),
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
                                onPressed: () {},
                                child: const Text(
                                  "Terms & Condition",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Privacy & Policy",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16.0),

                          const Text(
                            '© 2023 - UTSAVLIFE. All Rights Reserved.',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                )));
            },
          );
        },
      ),
    );
  }

  Widget CreateButton(BuildContext context, AuthProvider state) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                createService(state);
                setState(() {
                  isLoading = false;
                });
              },
              child: const Text("Save and Continue"),
            ),
          ),
        ],
      ),
    );
  }
  Widget InputField(String title, TextEditingController controller,
      {Icon leading = const Icon(Icons.person, color: Colors.grey),
        bool required = true,
        bool underline = false, // ✅ new
        MapProvider? state,
        bool isAadhar = false,
        bool hide = false,
        bool autoComplete = false,
        bool validatePhone = false,
        bool isCapital = false,
        bool isPin = false,
        bool isPrice = false}) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: validatePhone || isPin || isPrice
            ? TextInputType.phone
            : TextInputType.text,
        textCapitalization:
        isCapital ? TextCapitalization.characters : TextCapitalization.none,
        obscureText: hide,
        onChanged: autoComplete
            ? (text) {
          state!.getLocations(text);
          setState(() {
            showLocationList = true;
          });
        }
            : null,
        style: TextStyle(color: Colors.grey),
        decoration: InputDecoration(
          prefixIcon: leading,
          label: Text(title, style: TextStyle(color: Colors.grey)),
          focusedBorder: underline
              ? const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2))
              : OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: underline
              ? const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1))
              : OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        validator: required
            ? (text) {
          if (text == null || text.isEmpty) return "Required field";
          if (isAadhar && text.length < 12)
            return "Please enter a valid Aadhar number";
          if (validatePhone && (text.length < 10 || text.length > 15))
            return "Please enter a valid phone number";
          if (isPin && text.length != 6)
            return "Please enter a 6 digit pin code";
          return null;
        }
            : null,
      ),
    );
  }


  void createService(AuthProvider state) async {
    if (_formKey.currentState!.validate()) {
      if (serviceId.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Please select a service")));
        return;
      }
      if (_officePhone.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter office number")));
        return;
      }
      Map<String, dynamic> data = {
        "service_id": serviceId,
        "service_desc": _serviceDescription.text,
        "material_desc": _materialDescription.text,
        "office_pincode": _officePinCode.text,
        "office_house_no": _officeNo.text,
        "office_mobile": _officePhone.text,
        "office_area": _officeArea.text,
        "office_landmark": _officeLandmark.text,
        "office_city": _officeCity.text,
        "office_state": _officeState.text,
        "office_country": selectedOfficeCountry.id,
        "gst_no": _GST.text,
        "price": _price.text, //
        "driver_name": _driverName.text,
        "driver_mobile_no": _driverMob.text,
        "driver_kyc_type": _driverKycType.text,
        "dricer_kyc_no": _driverKycNo.text,
        "driver_licence_no": _driverLicense.text,
        "driver_pincode": _driverpinCode.text,
        "driver_house_no": _driverhouseNo.text,
        "driver_area": _driverArea.text,
        "driver_landmark": _driverLandmark.text,
        "driver_city": _driverCity.text,
        "driver_state": _driverState.text,
        "vendor_reg_part": 4,
        "img6": driverImage == null
            ? null
            : await MultipartFile.fromFile(driverImage!),
        "img5": drivingLicenseImage == null
            ? null
            : await MultipartFile.fromFile(drivingLicenseImage!),
        "video":
            videoPath == null ? null : await MultipartFile.fromFile(videoPath!)
      };
      for (int i = 0; i < productImages.length; i++) {
        data['pmg${i + 1}'] = productImages[i].filePath == null
            ? null
            : await MultipartFile.fromFile(productImages[i].filePath!);
      }
      CustomLogger.debug(data);
      try {
        await completeRegistrationIntermediate(state, data);
        state.setRegisterProgress(RegisterProgress.four);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Service created successfully")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class TermsAndConditionsPage extends StatefulWidget {
  TermsAndConditionsPage({Key? key});

  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _agreedToTerms = false;

  void _toggleTermsAgreement(bool? value) {
    setState(() {
      _agreedToTerms = value!;
    });
  }

  Future<void> submit(AuthProvider auth) async {
    try {
      await completeRegistrationTerms(auth);
    } catch (e) {
      CustomLogger.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, registerState, child) {
      return Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/signup1bg.jpg"),
                    fit: BoxFit.fitHeight)),
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
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                color: Colors.white,
                onPressed: () {
                  registerState.setRegisterProgress(RegisterProgress.five);
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              elevation: 0,
              title: Text(
                "Terms and Conditions",
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Container(
                            height: 200,
                            width: 200,
                            child: Image.asset("assets/images/logo/logo.png")),
                      ],
                    ),
                  ),
                  // Text(
                  //   'Terms and Conditions',
                  //   style: TextStyle(
                  //     fontSize: 18.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 16.0),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sed urna turpis. Nam fringilla odio id arcu aliquet, in vulputate justo feugiat. Suspendisse potenti. Sed feugiat, ligula vitae aliquam consequat, neque urna efficitur ligula, sit amet iaculis quam nisl ac mi. Donec nec dui luctus, convallis purus sit amet, luctus est. In volutpat eros arcu, ut luctus sem elementum ut. Nulla id leo id mauris vulputate consectetur. Sed cursus ligula id nisi vulputate lacinia. Nullam lacinia pulvinar dui, a ultrices ante vulputate eget.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sed urna turpis. Nam fringilla odio id arcu aliquet, in vulputate justo feugiat. Suspendisse potenti. Sed feugiat, ligula vitae aliquam consequat, neque urna efficitur ligula, sit amet iaculis quam nisl ac mi. Donec nec dui luctus, convallis purus sit amet, luctus est. In volutpat eros arcu, ut luctus sem elementum ut. Nulla id leo id mauris vulputate consectetur. Sed cursus ligula id nisi vulputate lacinia. Nullam lacinia pulvinar dui, a ultrices ante vulputate eget.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sed urna turpis. Nam fringilla odio id arcu aliquet, in vulputate justo feugiat. Suspendisse potenti. Sed feugiat, ligula vitae aliquam consequat, neque urna efficitur ligula, sit amet iaculis quam nisl ac mi. Donec nec dui luctus, convallis purus sit amet, luctus est. In volutpat eros arcu, ut luctus sem elementum ut. Nulla id leo id mauris vulputate consectetur. Sed cursus ligula id nisi vulputate lacinia. Nullam lacinia pulvinar dui, a ultrices ante vulputate eget.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.white),
                    child: CheckboxListTile(
                      checkColor: Colors.white,
                      checkboxShape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white, width: 0.5)),
                      value: _agreedToTerms,
                      onChanged: _toggleTermsAgreement,
                      title: Text(
                        'I agree to the terms and conditions',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: !_agreedToTerms
                        ? null
                        : () async {
                            await submit(registerState);
                            registerState.setRegisterProgress(
                                RegisterProgress.completed);
                            registerState.clear();
                            if (Navigator.canPop(context)) {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            } else {
                              Navigator.pushReplacementNamed(
                                  context, MainPage.routeName,
                                  arguments: true);
                            }
                          },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
