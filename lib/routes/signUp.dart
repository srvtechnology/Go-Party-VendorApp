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
import 'package:utsavlife/routes/singleServiceAdd.dart';
import 'package:utsavlife/routes/terms_privacy.dart';

import '../core/components/inputFields.dart';
import '../core/models/dropdown.dart';
import '../core/provider/ServiceProvider.dart';

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
                            Container(
                              child: CSCPicker(
                                disabledDropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                  color: Colors.transparent,
                                ),
                                selectedItemStyle:
                                    TextStyle(color: UIColor.black_text_color),
                                dropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                  color: Colors.transparent,
                                ),
                                currentCountry: selectedCountry,
                                currentState: selectedState,
                                currentCity: selectedCity,
                                onCountryChanged: (country) {
                                  selectedCountry = country ?? "";
                                },
                                onStateChanged: (state) {
                                  selectedState = state ?? "";
                                },
                                onCityChanged: (city) {
                                  setState(() {
                                    selectedCity = city ?? "";
                                    _address.text = city ?? "";
                                  });
                                },
                              ),
                            )
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
  TextEditingController _city = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _country = TextEditingController();
  Country selectedCountry = Country(id: "101", name: "India");

  // late DropDownField selectedKyc = kyctypes[0];
  late DropDownField? selectedKyc = null;
  bool isLoading = false;
  late Future _getCacheData;
  Future _getLocationData = Future.value({});
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
    _getCacheData = getDataFromCache();
    _pinCode.addListener(() async {
      if (_pinCode.text.length >= 6) {
        _getLocationData = _getLocationfromPinCode();
      }
    });
  }

  Future _getLocationfromPinCode() async {
    var data = await getCountryStateCityfromZip(_pinCode.text);
    CustomLogger.debug(data);
    setState(() {
      _country.text = data["country"]!;
      _state.text = data["state"]!;
      _city.text = data["city"]!;
    });
  }

  Future<void> getDataFromCache() async {
    _kycType.text = selectedKyc?.value ?? "";
    _pancard.text = context.read<AuthProvider>().user!.panCardNumber ?? "";
    _kycNo.text = context.read<AuthProvider>().user!.kycNumber ?? "";
    _pinCode.text = context.read<AuthProvider>().user!.zip ?? "";
    _houseNo.text = context.read<AuthProvider>().user!.houseNumber ?? "";
    _area.text = context.read<AuthProvider>().user!.area ?? "";
    _landmark.text = context.read<AuthProvider>().user!.landmark ?? "";
    _city.text = context.read<AuthProvider>().user!.city ?? "";
    _state.text = context.read<AuthProvider>().user!.state ?? "";
    _country.text = context.read<AuthProvider>().user!.country?.name ?? "";

    String kycType = context.read<AuthProvider>().user!.kycType ?? "";
    if (kycType != null && kycType.isNotEmpty) {
      //here we pre selecting the kyc type
      selectedKyc =
          kyctypes.where((element) => element.value == kycType).firstOrNull;
      _kycNo.text = context.read<AuthProvider>().user!.kycNumber ?? "";
    }
  }

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([_getCacheData, _getLocationData]),
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
                    CustomMaterialBox(listOfChildren: [
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
        "city": _city.text,
        "state": _state.text,
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
            setState(() {
              isLoading = true;
            });
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

class SignUp3 extends StatefulWidget {
  const SignUp3({Key? key}) : super(key: key);

  @override
  State<SignUp3> createState() => _SignUp3State();
}

class _SignUp3State extends State<SignUp3> {
  final _formKey = GlobalKey<FormState>();
  List<DropDownField> AccountTypes = [
    DropDownField(title: "Current Account", value: "current"),
    DropDownField(title: "Savings Account", value: "saving"),
    DropDownField(title: "Salary Account", value: "salary"),
    DropDownField(title: "Fixed Deposit Account", value: "fixed"),
    DropDownField(title: "Recurring Deposit Account", value: "recurring"),
    DropDownField(title: "NRI Account", value: "nri"),
  ];
  TextEditingController _bankName = TextEditingController();
  TextEditingController _AccountType = TextEditingController();
  TextEditingController _AccountNo = TextEditingController();
  TextEditingController _AccountNoConfirm = TextEditingController();
  TextEditingController _IFSCNo = TextEditingController();
  TextEditingController _HolderName = TextEditingController();
  TextEditingController _BranchName = TextEditingController();
  late DropDownField selectedAccount = AccountTypes[0];
  String? passbookPath;
  bool isLoading = false;
  late Future _getCacheData;
  List<String> dataKeys = [
    "bank_name",
    "acc_no",
    "ifsc_no",
    "holder_name",
    "branch_name",
    "acc_type"
  ];

  @override
  void initState() {
    super.initState();
    _getCacheData = getDataFromCache();
  }

  Future<void> getDataFromCache() async {
    AuthProvider auth = context.read<AuthProvider>();
    selectedAccount = AccountTypes.firstWhere(
        (element) => element.value == auth.user!.bankDetails?.accountType,
        orElse: () => AccountTypes[0]);
    _AccountType.text = selectedAccount.value;
    _bankName.text = auth.user!.bankDetails?.bankName ?? "";
    _AccountNo.text = auth.user!.bankDetails?.accountNumber ?? "";
    _IFSCNo.text = auth.user!.bankDetails?.ifscNumber ?? "";
    _HolderName.text = auth.user!.bankDetails?.holderName ?? "";
    _BranchName.text = auth.user!.bankDetails?.bankName ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, state, child) {
      return FutureBuilder(
          future: _getCacheData,
          builder: (context, snapshot) {
            return Scaffold(
              extendBodyBehindAppBar: false,
              backgroundColor: UIColor.screen_bg,
              appBar: AppToolbar(
                toolbarTitle: "Bank details",
                onPressed: () {
                  state.setRegisterProgress(RegisterProgress.three);
                },
              ),
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    customDivider(),
                    CustomMaterialBox(listOfChildren: [
                      InputField("Bank Name", _bankName,
                          leading: Icon(
                            Icons.currency_rupee,
                            color: UIColor.black_text_color,
                          )),
                      Container(
                        padding:
                        textInputPadding,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person,
                                color: UIColor.prefix_icon_tint),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 20),
                            label: Text(
                              "Kyc Type (optional)",
                              style: TextStyle(color: UIColor.hint_text_color),
                            ),
                            suffixIcon: Icon(Icons.arrow_drop_down, color: UIColor.prefix_icon_tint,),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: UIColor.theme_color,
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
                                    collapsedTextColor: UIColor.black_text_color,
                                    trailing: Text(""),
                                    key: GlobalKey(),
                                    title: Text(selectedAccount.title),
                                    children: AccountTypes.map((e) => ListTile(
                                      onTap: () {
                                        setState(() {
                                          _AccountType.text = e.value;
                                          selectedAccount = e;
                                        });
                                      },
                                      title: Text(
                                        e.title,
                                        style: TextStyle(
                                            color: UIColor.hint_text_color),
                                      ),
                                    )).toList(),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      InputField("Account Number", _AccountNo,
                          accountConfirm: true),
                      InputField("Re-Enter Account Number", _AccountNoConfirm,
                          accountConfirm: true),
                      InputField("IFSC Code", _IFSCNo),
                      InputField("Holder Name", _HolderName),
                      InputField("Branch Name", _BranchName,
                          leading: Icon(
                            Icons.home_outlined,
                            color: UIColor.prefix_icon_tint,
                          )),
                      customDivider(),
                      Container(
                        padding:
                        textInputPadding,
                        child: Row(
                          children: [
                            Expanded(
                                child: passbookPath == null
                                    ? Text(
                                  "Cancelled Checkbook / Passbook Front page",
                                  style: TextStyle(
                                      color: UIColor.black_text_color),
                                )
                                    : Container(
                                    alignment: Alignment.centerLeft,
                                    height: 80,
                                    width: 80,
                                    child:
                                    Image.file(File(passbookPath!)))),
                            SizedBox(
                              width: 40,
                            ),
                            OutlinedButton(
                                onPressed: () async {
                                  XFile? file = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (file != null) {
                                    setState(() {
                                      passbookPath = file.path;
                                    });
                                  }
                                },
                                child: Text(
                                    passbookPath == null ? "Choose" : "Change"))
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

  Future<void> submit(AuthProvider state) async {
    if (_formKey.currentState!.validate()) {
      if (passbookPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Please Upload a cancelled Check or a passbook front page.")));
        setState(() {
          isLoading = false;
        });
        return;
      }
      Map<String, dynamic> data = {
        "bank_name": _bankName.text,
        "acc_no": _AccountNo.text,
        "ifsc_no": _IFSCNo.text,
        "holder_name": _HolderName.text,
        "branch_name": _BranchName.text,
        "acc_type": _AccountType.text,
        "img1": await MultipartFile.fromFile(passbookPath!),
        "vendor_reg_part": 5
      };
      setState(() {
        isLoading = false;
      });
      await completeRegistration2(state, data);
      state.setRegisterProgress(RegisterProgress.five);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your data has been successfully recorded.")));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget SignUpButton(BuildContext context, AuthProvider state) {
    return Row(
      children: [
        Expanded(child: GradientButton(text: "Skip",colors: [UIColor.error_color,UIColor.error_color], onPressed: ()=>  state.setRegisterProgress(RegisterProgress.five))),
        Expanded(
          child: GradientButton(text: "Save and Continue", onPressed: () async {
            try {
              setState(() {
                isLoading = true;
              });
              await submit(state);
            } catch (e) {
              setState(() {
                isLoading = false;
              });
              CustomLogger.error(e);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString())));
            }
          }),
        ),

      ],
    );
  }

  Widget InputField(String title, TextEditingController controller,
      {Icon leading = const Icon(
        Icons.person,
        color: UIColor.prefix_icon_tint,
      ),
      bool hide = false,
      bool autocomplete = true,
      bool accountConfirm = false}) {
    return Container(
      margin: textInputPadding,
      child: TextFormField(
          keyboardType:
              accountConfirm ? TextInputType.number : TextInputType.text,
          obscureText: hide,
          controller: controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (text) {
            if (text?.length == 0) return "Required field";
            if (accountConfirm) {
              if (_AccountNo.text.length < 8 || _AccountNo.text.length > 20)
                return "Enter Valid Account Number";
              if (_AccountNo.text != _AccountNoConfirm.text)
                return "Account Numbers do not match";
            }
            return null;
          },
          style: TextStyle(color: UIColor.black_text_color),
          decoration: InputDecoration(
            prefixIcon: leading,
            label: Text(
              title,
              style: TextStyle(color: UIColor.hint_text_color),
            ),

          )),
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
                      margin:
                      textInputPadding,
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
                        margin:
                        textInputPadding,
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
                        margin:
                        textInputPadding,
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
                      ),]),
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
   return GradientButton(text: "Save and Continue", onPressed: () async {
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
  TextEditingController _companyName = TextEditingController();
  TextEditingController _videoLink = TextEditingController();
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
    /*   DropDownField(title: "Other Govt. Id", value: "OT"), */
  ];

  late Country selectedOfficeCountry;

  Future<void> getDataFromCache() async {
    AuthProvider auth = context.read<AuthProvider>();
    CustomLogger.debug(auth.user);
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

    /*added by me*/

    _companyName.text = auth.user!.service?.companyName ?? "";
    _videoLink.text = auth.user!.service?.videoUrl ?? "";
    //serviceId=auth.user!.service?.id ?? "";
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
          create: (_) =>
              DropDownOptionProvider(auth: Provider.of<AuthProvider>(context)),
        ),
        ChangeNotifierProvider(create: (_) => MapProvider())
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
                builder: (context, mapState, child) => Scaffold(
                  extendBodyBehindAppBar: false,
                  backgroundColor: UIColor.screen_bg,
                  appBar: AppToolbar(
                    toolbarTitle: "Office Details",
                    onPressed: () {
                      regState.setRegisterProgress(RegisterProgress.two);
                    },
                  ),
                  body: Form(
                    key: _formKey,
                    child: Container(
                      padding: EdgeInsets.all(11),
                      height: double.infinity,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(children: [
                          /*   Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              children: [
                                Container(
                                    height: 200,
                                    width: 200,
                                    child: Image.asset(
                                        "assets/images/logo/logo.png")),
                              ],
                            ),
                          ),*/

                          /*start of service details*/

                          CustomMaterialBox(heading:"Service Details",listOfChildren: [
                            Padding(
                              padding: textInputPadding,
                              child: ExpansionTile(
                                collapsedShape: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)),
                                shape: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: UIColor.theme_color),
                                    borderRadius: BorderRadius.circular(10)),
                                textColor: UIColor.black_text_color,
                                iconColor: Colors.grey,
                                collapsedIconColor: Colors.grey,
                                collapsedTextColor: UIColor.black_text_color,
                                key: GlobalKey(),
                                title: Text(
                                  serviceOption,
                                  style: TextStyle(
                                      color: Colors.grey),
                                ),
                                children: state.options!.serviceOptions
                                    .map(
                                      (e) => ListTile(
                                        title: Text(
                                          e.service,
                                          style: TextStyle(
                                              color: UIColor.black_text_color),
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
                            ),
                            InputField(
                                "Service Description", _serviceDescription,
                                leading: Icon(
                                  Icons.description,
                                  color: UIColor.prefix_icon_tint,
                                )),
                            InputField(
                                "Material Description", _materialDescription,
                                leading: Icon(
                                  Icons.description_outlined,
                                  color: UIColor.prefix_icon_tint,
                                )),
                            InputField("Company Name (optional)", _companyName,
                                required: false,
                                leading: Icon(
                                  Icons.description_outlined,
                                  color: UIColor.prefix_icon_tint,
                                )),
                            InputField("Video Link", _videoLink,
                                required: false,
                                leading: Icon(
                                  Icons.description_outlined,
                                  color: UIColor.prefix_icon_tint,
                                )),
                            InputField("Price", _price,
                                isPrice: true,
                                leading: Icon(
                                  Icons.currency_rupee,
                                  color: UIColor.prefix_icon_tint,
                                )),
                          ]),
                          customDivider(),
                          CustomMaterialBox(heading:"Product Image", listOfChildren: [
                            Container(
                              margin: textInputPadding,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Product Images (3 to 5)",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: UIColor.black_text_color),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        if (productImages.length >= 5) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Maximum 5 photos allowed")));
                                          return;
                                        }
                                        List<XFile?> images =
                                        await ImagePicker().pickMultiImage();
                                        setState(() {
                                          if (images.length > 5) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Maximum 5 photos allowed")));
                                          }
                                          images.forEach((element) {
                                            if (productImages.length == 5) return;
                                            productImages.add(AddProductPhoto(
                                                filePath: element?.path,
                                                id: productImages.length,
                                                onDelete: (id) {
                                                  setState(() {
                                                    productImages.removeWhere(
                                                            (element) =>
                                                        element.id == id);
                                                  });
                                                }));
                                          });
                                        });
                                      },
                                      child: const Text("Add"))
                                ],
                              ),
                            ),
                            ...productImages,

                          ]),
                          customDivider(),

                          CustomMaterialBox(heading: "Office Address", listOfChildren: [
                            if (serviceOption.toLowerCase().endsWith("car"))
                              Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                    child: Text(
                                      "Driver details",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: UIColor.black_text_color),
                                    ),
                                  ),
                                  InputField("Name", _driverName),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, top: 30),
                                    child: IntlPhoneField(
                                      initialCountryCode: "IN",
                                      showCountryFlag: false,
                                      dropdownIcon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: UIColor.prefix_icon_tint,
                                      ),
                                      style: TextStyle(
                                          color: UIColor.black_text_color),
                                      dropdownTextStyle: TextStyle(
                                          color: UIColor.black_text_color),
                                      decoration: InputDecoration(
                                        label: Text(
                                          "Phone Number",
                                          style: TextStyle(
                                              color: UIColor.hint_text_color),
                                        ),

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
                                        _driverMob.text = number.completeNumber;
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.person,
                                            color: UIColor.black_text_color),
                                        contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                        label: Text(
                                          "Kyc Type",
                                          style: TextStyle(
                                              color: UIColor.black_text_color),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: UIColor.black_text_color,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: ExpansionTile(
                                                trailing: Text(""),
                                                key: GlobalKey(),
                                                title: Text(
                                                  selectedKyc.title,
                                                  style: TextStyle(
                                                      color:
                                                      UIColor.black_text_color),
                                                ),
                                                children: kyctypes
                                                    .map((e) => ListTile(
                                                  onTap: () {
                                                    setState(() {
                                                      _driverKycType.text =
                                                          e.value;
                                                      selectedKyc = e;
                                                    });
                                                  },
                                                  title: Text(
                                                    e.title,
                                                    style: TextStyle(
                                                        color: UIColor
                                                            .black_text_color),
                                                  ),
                                                ))
                                                    .toList(),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  InputField(
                                      "${selectedKyc.title} Number", _driverKycNo,
                                      isAadhar: true),
                                  InputField("License", _driverLicense),
                                  InputField("House Number", _driverhouseNo),
                                  InputField(
                                      "Street/Sector/Village/Area", _driverArea),
                                  InputField("Landmark", _driverLandmark),
                                  InputField("City", _driverCity),
                                  InputField("PinCode", _driverpinCode,
                                      isPin: true),
                                  InputField("State", _driverState),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text(
                                      "Choose Driver Image",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: UIColor.black_text_color),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 25),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 60,
                                          child: driverImage != null
                                              ? Image.file(File(driverImage!))
                                              : Container(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          child: ElevatedButton(
                                            child: const Text("Choose"),
                                            onPressed: () async {
                                              XFile? image = await ImagePicker()
                                                  .pickImage(
                                                  source:
                                                  ImageSource.gallery);
                                              setState(() {
                                                driverImage = image?.path;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text(
                                      "Choose Driving License Image",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: UIColor.black_text_color),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 25),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          width: 80,
                                          height: 60,
                                          child: drivingLicenseImage != null
                                              ? Image.file(
                                              File(drivingLicenseImage!))
                                              : Container(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          child: ElevatedButton(
                                            child: const Text("Choose"),
                                            onPressed: () async {
                                              XFile? image = await ImagePicker()
                                                  .pickImage(
                                                  source:
                                                  ImageSource.gallery);
                                              setState(() {
                                                drivingLicenseImage = image?.path;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),

                            /*end of service details*/

                            Container(
                              child: IntlPhoneField(
                                initialValue: _officePhone.text,
                                initialCountryCode: "IN",
                                showCountryFlag: false,
                                dropdownIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                                style: TextStyle(color: UIColor.black_text_color),
                                dropdownTextStyle:
                                TextStyle(color: UIColor.black_text_color),
                                decoration: InputDecoration(
                                  label: Text(
                                    "Phone Number",
                                    style: TextStyle(
                                        color: UIColor.hint_text_color),
                                  ),

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
                                  _officePhone.text = number.completeNumber;
                                },
                              ),
                            ),
                            InputField("GST Number", _GST,
                                isCapital: true,
                                required: false,
                                leading: Icon(
                                  Icons.numbers,
                                  color: UIColor.prefix_icon_tint,
                                )),
                            InputField("PinCode", _officePinCode,
                                leading: Icon(
                                  Icons.pin_drop,
                                  color: UIColor.prefix_icon_tint,
                                ),
                                isPin: true),
                            InputField(
                                "Flat / House / Building Number", _officeNo,
                                leading: Icon(
                                  Icons.home_filled,
                                  color: UIColor.prefix_icon_tint,
                                )),
                            InputField("Street/Sector/Village/Area", _officeArea,
                                leading: Icon(
                                  Icons.home_filled,
                                  color: UIColor.prefix_icon_tint,
                                )),
                            InputField("Landmark", _officeLandmark,
                                leading: Icon(
                                  Icons.home_filled,
                                  color: UIColor.prefix_icon_tint,
                                )),
                          ]),
                          customDivider(),
                          CustomMaterialBox(listOfChildren: [
                            snapshot.connectionState ==
                                ConnectionState.waiting
                                ? Container(
                              height: 80,
                            )
                                : CSCPicker(
                              showStates: true,
                              showCities: true,
                              disabledDropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey,
                                    width: 1),
                                color: Colors.transparent,
                              ),
                              currentCountry: selectedOfficeCountry.name,
                              currentCity: _officeCity.text,
                              currentState: _officeState.text,
                              selectedItemStyle: TextStyle(
                                  color: UIColor.black_text_color),
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey,
                                    width: 1),
                                color: Colors.transparent,
                              ),
                              onCountryChanged: (country) {
                                setState(() {
                                  _officeCountry.text = country;
                                });
                              },
                              onStateChanged: (state) {
                                setState(() {
                                  _officeState.text = state ?? "";
                                });
                              },
                              onCityChanged: (city) {
                                setState(() {
                                  _officeCity.text = city ?? "";
                                });
                              },
                            ),
                          ]),

                          customDivider(),
                          if (isLoading)
                            Container(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            )
                          else
                            CreateButton(context, regState),

                          customDivider()
                        ]),
                      ),
                    ),
                  ),
                ),
              );
            });
      }),
    );
  }

  Widget CreateButton(BuildContext context, AuthProvider state) {
   return GradientButton(text: "Save and Continue",  onPressed: () {
     setState(() {
       isLoading = true;
     });
     createService(state);
     setState(() {
       isLoading = false;
     });
   });
  }

  Widget InputField(String title, TextEditingController controller,
      {Icon leading = const Icon(
        Icons.person,
        color: UIColor.prefix_icon_tint,
      ),
      bool required = true,
      MapProvider? state,
      bool isAadhar = false,
      bool hide = false,
      bool autoComplete = false,
      bool validatePhone = false,
      bool isCapital = false,
      bool isPin = false,
      bool isPrice = false}) {
    if (validatePhone) {
      if (!controller.text.startsWith("+91"))
        controller.text = "+91" + controller.text;
    }
    return Container(
      margin: textInputPadding,
      child: TextFormField(
        keyboardType: validatePhone || isPin || isPrice
            ? TextInputType.phone
            : TextInputType.text,
        textCapitalization:
            isCapital ? TextCapitalization.characters : TextCapitalization.none,
        obscureText: hide,
        controller: controller,
        onChanged: autoComplete
            ? (text) {
                state!.getLocations(text);
                setState(() {
                  showLocationList = true;
                });
              }
            : null,
        style: TextStyle(color: UIColor.black_text_color),
        decoration: InputDecoration(
          prefixIcon: leading,
          label: Text(
            title,
            style: TextStyle(color: UIColor.hint_text_color),
          ),
        ),
        validator: required
            ? (text) {
                if (text == null || text.length == 0) {
                  return "Required field";
                }
                if (isAadhar) {
                  if (text.length < 12) {
                    return "Please enter a valid Aadhar number";
                  }
                }
                if (validatePhone) {
                  if (text.length < 10 || text.length > 15) {
                    return "Please enter a valid phone number";
                  }
                }
                if (isPin) {
                  if (text.length != 6) {
                    return "Please enter a 6 digit pin code";
                  }
                }
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
            videoPath == null ? null : await MultipartFile.fromFile(videoPath!),
        "company_name": _companyName.text,
        "video_url": _videoLink.text,
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
        body: SingleChildScrollView( // Allows scrolling if content overflows
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligns all content to start
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
                                        urlToLoad: Constant.link_terms_condition),
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
                                        urlToLoad: Constant.link_privacy_policy),
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
                GradientButton(text: "Save", onPressed: () async {

                  if(_agreedPrivacy && _agreedPrivacy){
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
