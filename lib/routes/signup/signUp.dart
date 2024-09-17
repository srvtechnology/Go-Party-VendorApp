import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/components/CountryPicker.dart';
import 'package:utsavlife/core/components/appToolbar.dart';
import 'package:utsavlife/core/components/customBox.dart';
import 'package:utsavlife/core/components/gradientButton.dart';
import 'package:utsavlife/core/components/loading.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/RegisterProvider.dart';
import 'package:utsavlife/core/provider/mapProvider.dart';
import 'package:utsavlife/core/repo/auth.dart';
import 'package:utsavlife/core/repo/maps.dart';
import 'package:utsavlife/core/utils/Constant.dart';
import 'package:utsavlife/core/utils/UIColor.dart';
import 'package:utsavlife/core/utils/geolocator.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/core/utils/textformatters.dart';
import 'package:utsavlife/core/utils/validator.dart';
import 'package:utsavlife/routes/mainpage.dart';
import 'package:utsavlife/routes/service/singleServiceAdd.dart';
import 'package:utsavlife/routes/terms_privacy.dart';

import '../../core/components/HtmlInputBox.dart';
import '../../core/components/inputFields.dart';
import '../../core/models/dropdown.dart';
import '../../core/provider/ServiceProvider.dart';
import 'SignUpBank.dart';
import 'SignUpIntermediate.dart';

const EdgeInsets textInputPadding =
    EdgeInsets.symmetric(vertical: 8, horizontal: 0);

class SignUp extends StatefulWidget {
  bool dialogShow = false;
  static const routeName = "signup";

  SignUp({Key? key, this.dialogShow = false}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  void initState() {
    super.initState();
    if (widget.dialogShow) {
      Future.delayed(Duration(milliseconds: 200), () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text("Please complete your registration to proceed"),
              );
            });
      });
    }
  }

  @override
  Widget build(context) {
    return Consumer<AuthProvider>(builder: (context, auth, child) {
      CustomLogger.debug("progress is ${auth.user?.progress}");
      if (auth.isLoading) {
        return LoadingWidget();
      }
      if (auth.user == null) {
        return SignUp1();
      }
      if (auth.user!.progress == RegisterProgress.two) {
        return SignUp2();
      }
      if (auth.user!.progress == RegisterProgress.three) {
        return SignUpIntermediate();
      }
      if (auth.user!.progress == RegisterProgress.four) {
        return SignUp3();
      }
      if (auth.user!.progress == RegisterProgress.five) {
        return SignUp4();
      }
      if (auth.user!.progress == RegisterProgress.six) {
        return TermsAndConditionsPage();
      }
      return SignUp1();
    });
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
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          }
          return SafeArea(
            child: ListenableProvider(
              create: (_) => MapProvider(),
              child: Consumer2<MapProvider, AuthProvider>(
                builder: (context, mapState, registerState, child) =>
                    GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus!.unfocus();
                  },
                  child: Scaffold(
                    extendBodyBehindAppBar: false,
                    backgroundColor: UIColor.screen_bg,
                    appBar: AppToolbar(
                      toolbarTitle: "Basic Information",
                      onPressed: () {
                        registerState.logout();
                        Navigator.pushReplacementNamed(
                            context, MainPage.routeName);
                      },
                    ),
                    body: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          customDivider(),
                          CustomMaterialBox(listOfChildren: [
                            CustomInputField("Full Name", _name),
                            CustomInputField("Email", _email,
                                leading: Icon(
                                  Icons.email,
                                  color: UIColor.prefix_icon_tint,
                                ),
                                validateEmail: true),
                            Container(
                                padding: textInputPadding,
                                child: InputField(
                                  title: "Password",
                                  controller: _password,
                                  isPassword: true,
                                  obscureText: true,
                                  leading: Icon(Icons.password,
                                      color: UIColor.prefix_icon_tint),
                                )),
                            Container(
                              padding: textInputPadding,
                              child: IntlPhoneField(
                                initialCountryCode: "IN",
                                showCountryFlag: false,
                                dropdownIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: UIColor.prefix_icon_tint,
                                ),
                                style:
                                    TextStyle(color: UIColor.black_text_color),
                                dropdownTextStyle:
                                    TextStyle(color: UIColor.black_text_color),
                                decoration: InputDecoration(
                                  label: Text(
                                    "Phone Number",
                                    style: TextStyle(
                                        color: UIColor.hint_text_color),
                                  ),
                                  /*                focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: UIColor.theme_color,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: UIColor.black_text_color,
                                              width: 1.0,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 1.0,
                                            ),
                                          ),*/
                                ),
                                validator: (text) {
                                  if (text == null ||
                                      text.completeNumber.isEmpty) {
                                    return "Required field";
                                  }
                                  if (text.completeNumber.length < 12 ||
                                      text.completeNumber.length > 15) {
                                    return "Please enter a valid number";
                                  }
                                  return null;
                                },
                                onChanged: (number) {
                                  _mobileNo.text = number.completeNumber;
                                },
                              ),
                            ),
                          ]),
                          customDivider(),
                          CustomMaterialBox(listOfChildren: [
                            CountryPicker(
                                country: selectedCountry,
                                state: selectedState,
                                city: selectedCity,
                                pinCode: "",
                                onCountryChanged: (value) =>
                                    selectedCountry = value,
                                onStateChanged: (value) =>
                                    selectedState = value ?? "",
                                onCityChanged: (value)  {
                                  selectedCity = value ?? "";
                                  _address.text=selectedCity;

                                })
                          ]),
                          customDivider(),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                          //   child: DropdownSearch<String>(
                          //     items: DefaultCities,
                          //     selectedItem: _address.text,
                          //     validator: (text){
                          //       if(text==null) return "Required";
                          //     },
                          //     dropdownDecoratorProps: DropDownDecoratorProps(
                          //       baseStyle: TextStyle(color: Colors.white),
                          //       dropdownSearchDecoration: InputDecoration(
                          //         suffixIconColor: Colors.white,
                          //         prefixIcon: Icon(Icons.home,color: Colors.white,),
                          //         label: Text("City",style: TextStyle(color: Colors.white),),
                          //         focusedBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(10.0),
                          //           borderSide: BorderSide(
                          //             color: Colors.blue,
                          //           ),
                          //         ),
                          //         enabledBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(10.0),
                          //           borderSide: BorderSide(
                          //             color: Colors.white,
                          //             width: 1.0,
                          //           ),
                          //         ),
                          //       )
                          //     ),
                          //     onChanged: (text){
                          //       setState(() {
                          //         _address.text = text!;
                          //       });
                          //     },
                          //   ),
                          // ),
                          // if(showLocationList&&mapState.locations.isNotEmpty)
                          //   ListView.builder(
                          //       physics: ClampingScrollPhysics(),
                          //       shrinkWrap: true,itemCount: min(6, mapState.locations.length),itemBuilder: (context,index)=>ListTile(leading: Icon(Icons.location_on),title: Text(mapState.locations[index]),onTap: (){
                          //     _address.text = mapState.locations[index];
                          //     setState(() {
                          //       showLocationList=false;
                          //     });
                          //   },)),
                          if (isLoading)
                            Container(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            )
                          else
                            SignUpButton(context, mapState, registerState),
                        ],
                      )),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
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
        "address_latitude": 0, //mapState.coordinates.latitude,
        "address_longitude": 0, //mapState.coordinates.longitude
        "vendor_reg_part": 2
      };
      CustomLogger.debug(data);
      await signUpMain(data);
      await registerState.login(_email.text, _password.text);
      registerState.setRegisterProgress(RegisterProgress.two);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget SignUpButton(
      BuildContext context, MapProvider mapState, AuthProvider registerState) {
    return GradientButton(
        text: "Save and Continue",
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
        });
    /*return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: UIColor.theme_color),
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
              child: const Text(
                "Save and Continue",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );*/
  }

  Widget CustomInputField(String title, TextEditingController controller,
      {Icon leading = const Icon(
        Icons.person,
        color: UIColor.prefix_icon_tint,
      ),
      bool hide = false,
      bool autocomplete = true,
      MapProvider? state,
      validateEmail = false,
      validatePhone = false}) {
    if (validatePhone) {
      if (!controller.text.startsWith("+91"))
        controller.text = "+91" + controller.text;
    }
    return Container(
      margin: textInputPadding,
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(0)),
        child: TextFormField(
            style: TextStyle(color: UIColor.black_text_color),
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
              if (validateEmail && !isValidEmail(text!)) {
                return "Please enter a valid email ID";
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (text) {
              //  _formKey.currentState?.validate();
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
                style: TextStyle(color: UIColor.hint_text_color),
              ),
            )),
      ),
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
  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar", value: "AD"),
    DropDownField(title: "Voter Id", value: "VO"),
    DropDownField(title: "Passport", value: "PA"),
    DropDownField(title: "Driving License", value: "DL"),
    /*    DropDownField(title: "Other Govt. Id", value: "OT"), */
  ];
  final _scrollKey = PageStorageKey("scroll");
  TextEditingController _pancard = TextEditingController();
  TextEditingController _kycType = TextEditingController();
  TextEditingController _kycNo = TextEditingController();
  TextEditingController _pinCode = TextEditingController();
  TextEditingController _houseNo = TextEditingController();
  TextEditingController _area = TextEditingController();
  TextEditingController _landmark = TextEditingController();

  Country selectedCountry = Country(id: "101", name: "India");

  String pinCode = "";
  String _city = "", _state = "", _country = "";

  // late DropDownField selectedKyc = kyctypes[0];
  late DropDownField? selectedKyc = null;
  bool isLoading = false;
  late Future _getCacheData;

  List<String> dataKeys = [
    "pan_card",
    "kyc_type",
    "kyc_no",
    "pin_code",
    "house_no",
    "area",
    "landmark",
    "city",
    "state",
    "country"
  ];

  @override
  void initState() {
    super.initState();
    _pinCode.addListener(() {
      if (_pinCode.text.length >= 6)
        setState(() {
          pinCode = _pinCode.text;
        });
    });
    _getCacheData = getDataFromCache();
  }

  Future<void> getDataFromCache() async {
    _kycType.text = selectedKyc?.value ?? "";
    _pancard.text = context.read<AuthProvider>().user!.panCardNumber ?? "";
    _pancard.text = _pancard.text.toUpperCase();
    _kycNo.text = context.read<AuthProvider>().user!.kycNumber ?? "";
    _pinCode.text = context.read<AuthProvider>().user!.zip ?? "";
    _houseNo.text = context.read<AuthProvider>().user!.houseNumber ?? "";
    _area.text = context.read<AuthProvider>().user!.area ?? "";
    _landmark.text = context.read<AuthProvider>().user!.landmark ?? "";
    _city = context.read<AuthProvider>().user!.city ?? "";
    _state = context.read<AuthProvider>().user!.state ?? "";
    _country = context.read<AuthProvider>().user!.country?.name ?? "";

    String kycType = context.read<AuthProvider>().user!.kycType ?? "";
    if (kycType.isNotEmpty) {
      //here we pre selecting the kyc type
      selectedKyc = kyctypes.where((element) => element.value == kycType).first;
      _kycType.text = selectedKyc?.value ?? "";
      _kycNo.text = context.read<AuthProvider>().user!.kycNumber ?? "";
    }
  }

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([_getCacheData]),
        builder: (context, snapshot) {
          return Consumer<AuthProvider>(builder: (context, state, child) {
            return Scaffold(
              extendBodyBehindAppBar: false,
              backgroundColor: UIColor.screen_bg,
              appBar: AppToolbar(
                toolbarTitle: "Personal Information",
                onPressed: () {
                  state.logout();
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  CustomLogger.debug(state.authState);
                },
              ),
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    //key: PageStorageKey<String>("try"),
                    child: Column(
                  children: [
                    customDivider(),
                    CustomMaterialBox(listOfChildren: [
                      InputField("Pan Number", _pancard,
                          uppercase: true,
                          leading: Icon(
                            Icons.numbers,
                            color: UIColor.prefix_icon_tint,
                          ), validator: (text) {
                        //                        if (text == null || text.isEmpty) return null;
                        if (text?.length != 10 ||
                            (isNumeric(text!.substring(0, 5))) ||
                            (!isNumeric(text!.substring(5, 9))) ||
                            (isNumeric(text!.substring(9, 10))))
                          return "Please enter a valid Pan Number";
                        return null;
                      }),
                      Container(
                        margin: textInputPadding,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            prefixIcon: Icon(
                              Icons.person,
                              color: UIColor.prefix_icon_tint,
                            ),
                            label: Text(
                              "Kyc Type",
                              style: TextStyle(color: Colors.grey),
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
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  child: ExpansionTile(
                                collapsedTextColor: UIColor.prefix_icon_tint,
                                trailing: Icon(
                                  Icons.arrow_drop_down,
                                  color: UIColor.prefix_icon_tint,
                                ),
                                key: GlobalKey(),
                                initiallyExpanded: _isExpanded,
                                onExpansionChanged: (value) {
                                  setState(() {
                                    _isExpanded = value;
                                  });
                                },
                                title: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _kycType.clear();
                                      _kycNo.clear();
                                      selectedKyc = null;
                                      _isExpanded =
                                          !_isExpanded; // Toggle expansion state
                                    });
                                  },
                                  child: Text(
                                    selectedKyc == null || _isExpanded
                                        ? "Select KYC type"
                                        : selectedKyc!.title,
                                    style: TextStyle(
                                        color: UIColor.black_text_color),
                                  ),
                                ),
                                children: kyctypes
                                    .map((e) => ListTile(
                                          onTap: () {
                                            setState(() {
                                              _kycType.text = e.value;
                                              selectedKyc = e;
                                              _isExpanded =
                                                  !_isExpanded; // Toggle expansion state
                                            });
                                          },
                                          title: Text(
                                            e.title,
                                            style: TextStyle(
                                                color:
                                                    UIColor.black_text_color),
                                          ),
                                        ))
                                    .toList(),
                              ))
                            ],
                          ),
                        ),
                      ),
                      if (selectedKyc != null)
                        InputField("${selectedKyc?.title} Number", _kycNo,
                            validator: (text) {
                          //  if (selectedKyc == null) return null;
                          if (text == null || text.isEmpty)
                            return "Please enter a valid number";
                          if (selectedKyc?.value == "AD" && text.length != 12)
                            return "Please enter a valid aadhar number";

                          if (selectedKyc?.value == "DL" &&
                              (text.length < 15 || text.length > 16)) {
                            return "Please enter a valid driving licence number (15-16 characters)";
                          }

                          if (selectedKyc?.value == "PA" && text.length != 8)
                            return "Please enter a valid passport number";

                          if (selectedKyc?.value == "VO" && text.length != 10)
                            return "Please enter a valid voter number";

                          return null;
                        }),
                      InputField("Pin code", _pinCode,
                          leading: Icon(
                            Icons.pin_drop,
                            color: UIColor.prefix_icon_tint,
                          ),
                          keyboardType: TextInputType.phone, validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "Required Field";
                        }
                        if (text.length != 6) {
                          return "Please enter a 6 digit valid pincode";
                        }
                        return null;
                      }),
                      InputField("Flat / House / Building Number", _houseNo,
                          validator: null,
                          leading: Icon(
                            Icons.home_filled,
                            color: UIColor.prefix_icon_tint,
                          )),
                      InputField("Street/Sector/Village/Area", _area,
                          leading: Icon(
                            Icons.home_filled,
                            color: UIColor.prefix_icon_tint,
                          )),
                      InputField("Landmark", _landmark,
                          leading: Icon(
                            Icons.home_filled,
                            color: UIColor.prefix_icon_tint,
                          )),
                    ]),
                    customDivider(),
                    /*   CustomMaterialBox(listOfChildren: [
                      snapshot.connectionState == ConnectionState.waiting
                          ? Container(
                              height: 80,
                            )
                          : CSCPicker(
                              flagState: CountryFlag.DISABLE,
                              showStates: true,
                              showCities: true,
                              disabledDropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                color: Colors.transparent,
                              ),
                              currentCountry: _country.text,
                              currentCity: _city.text,
                              currentState: _state.text,
                              selectedItemStyle:
                                  TextStyle(color: UIColor.black_text_color),
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                color: Colors.transparent,
                              ),
                              onCountryChanged: (country) {
                                setState(() {
                                  _country.text = country;
                                });
                              },
                              onStateChanged: (state) {
                                setState(() {
                                  _state.text = state ?? "";
                                });
                              },
                              onCityChanged: (city) {
                                setState(() {
                                  _city.text = city ?? "";
                                });
                              },
                            ),
                    ]),*/
                   CustomMaterialBox(listOfChildren: [
                     CountryPicker(
                         pinCode: pinCode,
                         state: _state,
                         city: _city,
                         country: _country,
                         onCountryChanged: (country) {
                           _country = country;
                           },
                         onStateChanged: (state) {
                           _state = state ?? "";
                         },
                         onCityChanged: (city) {
                           _city = city ?? "";
                         })
                   ]),
                    customDivider(),
                    if (isLoading)
                      Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      )
                    else
                       SignUpButton(context, state),
                    customDivider()
                  ],
                )),
              ),
            );
          });
        });
  }

  Future<void> submit(AuthProvider state) async {
    setState(() {
      isLoading = true;
    });
    if (selectedKyc == null) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select KYC type.")));
    } else if (_formKey.currentState!.validate()) {
      Map data = {
        "pan_card": _pancard.text,
        "kyc_type": _kycType.text,
        "kyc_no": _kycNo.text,
        "pin_code": _pinCode.text,
        "house_no": _houseNo.text,
        "area": _area.text,
        "landmark": _landmark.text,
        "city": _city,
        "state": _state,
        "country": selectedCountry.id,
        "vendor_reg_part": 3
      };
      CustomLogger.debug(data);
      setState(() {
        isLoading = false;
      });
        await completeRegistration(state, data);
     state.setRegisterProgress(RegisterProgress.three);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your data has been successfully recorded.")));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget SignUpButton(BuildContext context, AuthProvider state) {
    return GradientButton(
        text: "Save and Continue",
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
        });
  }

  Widget InputField(String title, TextEditingController controller,
      {Icon leading = const Icon(
        Icons.person,
        color: UIColor.prefix_icon_tint,
      ),
      TextInputType keyboardType = TextInputType.text,
      bool hide = false,
      bool autocomplete = true,
      bool uppercase = false,
      String? Function(String? text)? validator}) {
    return Container(
      padding: textInputPadding,
      child: TextFormField(
          keyboardType: keyboardType,
          textCapitalization: uppercase
              ? TextCapitalization.characters
              : TextCapitalization.none,
          inputFormatters: uppercase ? [UpperCaseTextFormatter()] : null,
          obscureText: hide,
          controller: controller,
          validator: validator != null
              ? validator
              : (text) {
                  if (text?.length == 0) return "Required field";
                  return null;
                },
          style: TextStyle(color: UIColor.black_text_color),
          decoration: InputDecoration(
              prefixIcon: leading,
              label: Text(
                title,
                style: TextStyle(color: UIColor.hint_text_color),
              ))),
    );
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
      CustomLogger.debug(state.user?.gstNumber ?? "gst number is not provided");
      return FutureBuilder(
          future: _cache,
          builder: (context, snapshot) {
            return Scaffold(
              extendBodyBehindAppBar: false,
              backgroundColor: UIColor.screen_bg,
              appBar: AppToolbar(
                toolbarTitle: "KYC documents",
                onPressed: () {
                  state.setRegisterProgress(RegisterProgress.four);
                },
              ),
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    customDivider(),
                    CustomMaterialBox(listOfChildren: [
                      Container(
                        margin: textInputPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pan Card",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: UIColor.black_text_color,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: panUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: panUrl!,
                                          placeholder: (context, url) {
                                            return Container(
                                              alignment: Alignment.center,
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorWidget: (context, url, err) {
                                            return Icon(
                                              Icons.file_copy,
                                              size: 60,
                                              color: UIColor.prefix_icon_tint,
                                            );
                                          },
                                        )
                                      : imgPath["Pan Card"] == null
                                          ? Icon(
                                              Icons.file_copy,
                                              size: 60,
                                              color: UIColor.black_text_color,
                                            )
                                          : Image.file(
                                              File(imgPath["Pan Card"]!)),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      XFile? file = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      if (file != null) {
                                        int size = await file.length() ~/ 1024;
                                        if (size > 2048) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Image too big. Please select an image below 2mb")));
                                        } else {
                                          setState(() {
                                            imgPath["Pan Card"] = file.path;
                                            panUrl = null;
                                          });
                                        }
                                      }
                                    },
                                    child: Text("Choose File")),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (state.user?.gstNumber != null)
                        Container(
                          margin: textInputPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "GST (optional)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: UIColor.black_text_color,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: gst != null
                                        ? CachedNetworkImage(
                                            imageUrl: gst!,
                                            placeholder: (context, url) {
                                              return Container(
                                                alignment: Alignment.center,
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                            errorWidget: (context, str, err) {
                                              return Icon(
                                                Icons.file_copy,
                                                size: 60,
                                                color: UIColor.prefix_icon_tint,
                                              );
                                            },
                                          )
                                        : imgPath["GST"] == null
                                            ? Icon(
                                                Icons.file_copy,
                                                size: 60,
                                                color: UIColor.black_text_color,
                                              )
                                            : Image.file(File(imgPath["GST"]!)),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        FilePickerResult? file =
                                            await FilePicker.platform.pickFiles(
                                                allowedExtensions: [
                                              "pdf",
                                              "jpg",
                                              "jpeg"
                                            ],
                                                type: FileType.custom);
                                        if (file != null) {
                                          int size =
                                              await file.files.single.size ~/
                                                  1024;
                                          if (size > 2048) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Image too big. Please select an image below 2mb")));
                                          } else {
                                            setState(() {
                                              imgPath["GST"] =
                                                  file.files.single.path;
                                              gst = null;
                                            });
                                          }
                                        }
                                      },
                                      child: Text("Choose File")),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Container(
                        margin: textInputPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "KYC",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: UIColor.black_text_color,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: kyc != null
                                      ? CachedNetworkImage(
                                          imageUrl: kyc!,
                                          placeholder: (context, url) {
                                            return Container(
                                              alignment: Alignment.center,
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorWidget: (context, str, err) {
                                            return Icon(
                                              Icons.file_copy,
                                              size: 60,
                                              color: UIColor.prefix_icon_tint,
                                            );
                                          },
                                        )
                                      : imgPath["KYC"] == null
                                          ? Icon(
                                              Icons.file_copy,
                                              size: 60,
                                              color: UIColor.black_text_color,
                                            )
                                          : Image.file(File(imgPath["KYC"]!)),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      XFile? file = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      if (file != null) {
                                        int size = await file.length() ~/ 1024;
                                        if (size > 2048) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Image too big. Please select an image below 2mb")));
                                        } else {
                                          setState(() {
                                            imgPath["KYC"] = file.path;
                                            kyc = null;
                                          });
                                        }
                                      }
                                    },
                                    child: Text("Choose File")),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: textInputPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Vendor Picture (optional)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: UIColor.black_text_color,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: vendor != null
                                      ? CachedNetworkImage(
                                          imageUrl: vendor!,
                                          placeholder: (context, url) {
                                            return Container(
                                              alignment: Alignment.center,
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorWidget: (context, str, err) {
                                            return Icon(
                                              Icons.file_copy,
                                              size: 60,
                                              color: UIColor.prefix_icon_tint,
                                            );
                                          },
                                        )
                                      : imgPath["Vendor"] == null
                                          ? Icon(
                                              Icons.file_copy,
                                              size: 60,
                                              color: UIColor.black_text_color,
                                            )
                                          : Image.file(
                                              File(imgPath["Vendor"]!)),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      XFile? file = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      if (file != null) {
                                        int size = await file.length() ~/ 1024;
                                        if (size > 2048) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Image too big. Please select an image below 2mb")));
                                        } else {
                                          setState(() {
                                            imgPath["Vendor"] = file.path;
                                            vendor = null;
                                          });
                                        }
                                      }
                                    },
                                    child: Text("Choose File")),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
                    customDivider(),
                    if (isLoading)
                      Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      )
                    else
                      SignUpButton(context, state),
                  ],
                )),
              ),
            );
          });
    });
  }

  bool isImageUrl(String url) {
    // Get the last segment of the URL (i.e., the filename)
    List<String> segments = Uri.parse(url).pathSegments;
    String filename = segments.isNotEmpty ? segments.last : '';

    // List of image file extensions
    List<String> imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.svg',
      // Add more image extensions if needed
    ];

    // Check if the filename's extension is in the list of image extensions
    return imageExtensions
        .any((extension) => filename.toLowerCase().endsWith(extension));
  }

  Future<void> submit(AuthProvider state) async {
    if (imgPath["Pan Card"] == null && !isImageUrl(panUrl ?? '')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please provide PAN")));
      return;
    }

    if (imgPath["KYC"] == null && !isImageUrl(kyc ?? '')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please provide KYC")));
      return;
    }
    if (imgPath["Vendor"] == null && !isImageUrl(vendor ?? '')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please provide Vendor")));
      return;
    }
    if (state.user?.gstNumber != null &&
        (imgPath["GST"] == null && !isImageUrl(gst ?? ''))) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please provide GST")));
      return;
    }

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
    return GradientButton(
        text: "Save and Continue",
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
        });
  }
}



class TermsAndConditionsPage extends StatefulWidget {
  TermsAndConditionsPage({Key? key});

  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _agreedToTerms = false;
  bool _agreedPrivacy = false;

  void _toggleTermsAgreement(bool? value) {
    setState(() {
      _agreedToTerms = value!;
    });
  }

  void _togglePrivacy(bool? value) {
    setState(() {
      _agreedPrivacy = value!;
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
      return Scaffold(
        backgroundColor: UIColor.screen_bg,
        appBar: AppToolbar(
          toolbarTitle: "Terms and Conditions",
          onPressed: () {
            registerState.setRegisterProgress(RegisterProgress.five);
          },
        ),
        body: SingleChildScrollView(
          // Allows scrolling if content overflows
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Aligns all content to start
              children: <Widget>[
                const SizedBox(height: 16.0),
                Theme(
                  data: ThemeData(
                      unselectedWidgetColor: UIColor.black_text_color),
                  child: CheckboxListTile(
                    activeColor: UIColor.theme_color,
                    checkColor: Colors.white,
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.white, width: 0.5)),
                    value: _agreedToTerms,
                    onChanged: _toggleTermsAgreement,
                    title: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(color: UIColor.black_text_color),
                        ),
                        TextSpan(
                          text: Constant.label_terms_condition,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TermsPrivacy(
                                        title: Constant.label_terms_condition,
                                        urlToLoad:
                                            Constant.link_terms_condition),
                                  ));
                            },
                          style: TextStyle(
                              color: UIColor.theme_color,
                              decoration: TextDecoration.underline),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0), // Add spacing between checkboxes
                Theme(
                  data: ThemeData(
                      unselectedWidgetColor: UIColor.black_text_color),
                  child: CheckboxListTile(
                    activeColor: UIColor.theme_color,
                    checkColor: Colors.white,
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.white, width: 0.5)),
                    value: _agreedPrivacy,
                    onChanged: _togglePrivacy,
                    title: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(color: UIColor.black_text_color),
                        ),
                        TextSpan(
                          text: Constant.label_privacy_policy,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TermsPrivacy(
                                        title: Constant.label_privacy_policy,
                                        urlToLoad:
                                            Constant.link_privacy_policy),
                                  ));
                            },
                          style: TextStyle(
                              color: UIColor.theme_color,
                              decoration: TextDecoration.underline),
                        ),
                      ]),
                    ),
                  ),
                ),
                customDivider(),
                GradientButton(
                    text: "Save",
                    onPressed: () async {
                      if (_agreedPrivacy && _agreedPrivacy) {
                        await submit(registerState);
                        registerState
                            .setRegisterProgress(RegisterProgress.completed);
                        registerState.clear();
                        if (Navigator.canPop(context)) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        } else {
                          Navigator.pushReplacementNamed(
                              context, MainPage.routeName,
                              arguments: true);
                        }
                      }
                    })
              ],
            ),
          ),
        ),
      );
    });
  }
}

Widget customDivider() {
  return SizedBox(
    height: 20,
  );
}
