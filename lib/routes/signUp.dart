import 'dart:math';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
class SignUp extends StatefulWidget {
  bool dialogShow = false;
  static const routeName = "signup";
  SignUp({Key? key,this.dialogShow=false}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  void initState() {
    super.initState();
    if(widget.dialogShow){
      Future.delayed(Duration(milliseconds: 200),(){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: Text("Please complete your registration to proceed"),
          );
        });
      });
    }
  }
  @override
  Widget build(context){
    return  Consumer<AuthProvider>(
          builder:(context,auth,child){
            if(auth.isLoading){
              return LoadingWidget();
            }
            if(auth.user == null){
              return SignUp1();
            }
            if(auth.user!.progress == RegisterProgress.two){
              return SignUp2();
            }
            if(auth.user!.progress == RegisterProgress.three){
              return SignUpIntermediate();
            }
            if(auth.user!.progress == RegisterProgress.four){
              return SignUp3();
            }
            if(auth.user!.progress == RegisterProgress.five){
              return SignUp4();
            }
            if(auth.user!.progress == RegisterProgress.six){
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
  final TextEditingController _email=TextEditingController();
  final TextEditingController _name=TextEditingController();
  final TextEditingController _mobileNo=TextEditingController();
  final TextEditingController _password=TextEditingController();
  final TextEditingController _address=TextEditingController();
  final TextEditingController _area=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedCountry="",selectedCity="",selectedState="";
  late List<TextEditingController> _controllers;
  bool showLocationList = false ;
  bool isLoading = false;
  late Future _getLocation;
  List<String> dataKeys = [
    "name","email","password","mobile","address_address","distance_cover","address_latitude","address_longitude"];
  @override
  void initState() {
    _controllers = [
      _name,
      _email,
      _mobileNo,
      _password,
      _address,
      _area
    ];
    _getLocation=_initCountryStateCity();
    super.initState();
  }

  Future _initCountryStateCity()async{
    var data = await getCountryCityState();
    setState(() {
      selectedCountry=data["country"];
      selectedState=data["state"];
      selectedCity=data["city"];
      _address.text=selectedCity;
    });
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLocation,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
            body: Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          );
        }
        return SafeArea(
          child: ListenableProvider(create: (_)=>MapProvider(),
            child: Consumer2<MapProvider,AuthProvider>(
              builder:(context,mapState,registerState,child)=>GestureDetector(
                onTap: (){
                  FocusManager.instance.primaryFocus!.unfocus();
                },
                child: Stack(
                  children: [
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/signup5bg.jpg"),
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
                    Scaffold(
                      extendBodyBehindAppBar: true,
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        leading: IconButton(color: Colors.white,onPressed: (){
                          registerState.logout();
                          Navigator.pushReplacementNamed(context, MainPage.routeName);
                        },icon: Icon(Icons.arrow_back_ios),),
                        elevation: 0,
                        title: Text("Basic Information",style: TextStyle(fontWeight: FontWeight.w400),),
                        iconTheme: IconThemeData(color: Colors.black),
                      ),
                      body: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                            child:Container(
                              child: Column(children: [
                               Container(
                                 margin: EdgeInsets.only(left: 20,right: 20),
                                 child: Column(
                                   children: [
                                     Container(
                                         height:200,
                                         width: 200,
                                         child: Image.asset("assets/images/logo/logo.png")),
                                     Container(
                                       alignment: Alignment.center,
                                       margin:const EdgeInsets.only(bottom: 10),
                                       child: Text("Welcome",style: Theme.of(context).textTheme.headlineSmall!.copyWith(color:Colors.white),),
                                     ),
                                   ],
                                 ),
                               ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    children: [
                                      //SizedBox(height: 40,),
                                      CustomInputField("Full Name", _name),
                                      CustomInputField("Email", _email,leading: Icon(Icons.email,color: Colors.white,)),
                                      Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20,),
                                          margin: EdgeInsets.only(top: 10),
                                          child: InputField(
                                            title:"Password",controller: _password,isPassword:true,obscureText: true,leading: Icon(Icons.password),)),
                                      Container(
                                        padding: EdgeInsets.only(left: 40,right: 40,top: 30),
                                        child: IntlPhoneField(
                                          initialCountryCode: "IN",
                                          showCountryFlag: false,
                                          dropdownIcon: const Icon(Icons.arrow_drop_down,color: Colors.white,),
                                          style: TextStyle(color: Colors.white),
                                          dropdownTextStyle: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            label: Text("Phone Number",
                                              style: TextStyle(color: Colors.white),),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                          validator: (text){
                                            if(text==null || text.completeNumber.isEmpty){
                                              return "Required field";
                                            }
                                            if(text.completeNumber.length<12 || text.completeNumber.length>15){
                                              return "Please enter a valid number";
                                            }
                                          },
                                          onChanged: (number){
                                            _mobileNo.text = number.completeNumber;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                                        child: CSCPicker(

                                          disabledDropdownDecoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.white,width: 1),
                                            color: Colors.transparent,
                                          ),

                                          selectedItemStyle: TextStyle(color: Colors.white),
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.white,width: 1),
                                            color: Colors.transparent,
                                          ),
                                          currentCountry: selectedCountry,
                                          currentState: selectedState,
                                          currentCity: selectedCity,
                                          onCountryChanged: (country){
                                            selectedCountry = country??"";

                                          },
                                          onStateChanged: (state){
                                              selectedState = state??"";
                                          },
                                          onCityChanged: (city){
                                            setState(() {
                                              selectedCity = city??"";
                                              _address.text=city??"";
                                            });
                                          },
                                        ),
                                      ),
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
                                      if(isLoading)Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                                      else SignUpButton(context,mapState,registerState),
                                    ],
                                  ),
                                ),
                              ],),
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
  Future<void> submit(AuthProvider registerState,MapProvider mapState)async{
    if(_formKey.currentState!.validate()){
      Map<String,dynamic> data = {
        "name":_name.text.toString(),
        "email":_email.text,
        "password":_password.text,
        "mobile":_mobileNo.text,
        "address_address":_address.text,
        "distance_cover":0,
        "address_latitude":0,//mapState.coordinates.latitude,
        "address_longitude":0,//mapState.coordinates.longitude
        "vendor_reg_part":2
      } ;
      CustomLogger.debug(data);
      await signUpMain(data);
      await registerState.login(_email.text, _password.text);
      registerState.setRegisterProgress(RegisterProgress.two);
    }
    else{
      setState(() {
        isLoading=false;
      });
    }
  }
  Widget SignUpButton(BuildContext context,MapProvider mapState,AuthProvider registerState){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: ()async{
                try{
                  setState(() {
                    isLoading = true;
                  });
                  await submit(registerState,mapState);
                }catch(e){
                  setState(() {
                    isLoading = false;
                  });
                  CustomLogger.error(e);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text("Save and Continue"),
            ),
          ),
        ],
      ),
    );
  }
  Widget CustomInputField(String title,TextEditingController controller,{Icon leading=const Icon(Icons.person,color: Colors.white,),bool hide=false,bool autocomplete=true,MapProvider? state,validatePhone=false}){
    if(validatePhone){
      if(!controller.text.startsWith("+91"))
        controller.text="+91"+controller.text;
    }
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        keyboardType: validatePhone?TextInputType.phone:TextInputType.text,
        obscureText: hide,
        controller: controller,
        validator: (text){
          if(text?.length==0) return "Required field";
          if(validatePhone){
            if(text!=null && (text.length<10 || text.length>15)){
              return "Please enter a valid phone number";
            }
          }
        },
        onChanged: (text){
          if(state!=null){
            setState(() {
              showLocationList=true;
            });
            state.getLocations(text);
            CustomLogger.debug(state.locations);
          }
        },
        decoration: InputDecoration(
            prefixIcon: leading,
            label: Text(title,style: TextStyle(color: Colors.white),),
            focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                    color: Colors.blue,
                        ),
                    ),
            enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                    color: Colors.white,
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
  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar",value: "AD"),
    DropDownField(title: "Voter Id",value: "VO"),
    DropDownField(title: "Passport",value: "PA"),
    DropDownField(title: "Driving License",value: "DL"),
    DropDownField(title: "Other Govt. Id",value: "OT"),
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
  late DropDownField selectedKyc=kyctypes[0];
  bool isLoading = false;
  late Future _getCacheData ;
  Future _getLocationData = Future.value({});
  List<String> dataKeys = [
    "pan_card","kyc_type","kyc_no","pin_code","house_no","area","landmark","city","state","country"
  ];

  @override
  void initState() {
    super.initState();
    _getCacheData = getDataFromCache();
    _pinCode.addListener(() async{
      if(_pinCode.text.length>=6){
        _getLocationData = _getLocationfromPinCode();
      }
    });
  }

  Future _getLocationfromPinCode()async{
    var data =await getCountryStateCityfromZip(_pinCode.text);
    CustomLogger.debug(data);
    setState(() {
      _country.text=data["country"]!;
      _state.text=data["state"]!;
      _city.text=data["city"]!;
    });
  }
  Future<void> getDataFromCache()async{
    _kycType.text = selectedKyc.value;
    _pancard.text=context.read<AuthProvider>().user!.panCardNumber??"";
    _kycNo.text=context.read<AuthProvider>().user!.kycNumber??"";
    _pinCode.text=context.read<AuthProvider>().user!.zip??"";
    _houseNo.text=context.read<AuthProvider>().user!.houseNumber??"";
    _area.text=context.read<AuthProvider>().user!.area??"";
    _landmark.text=context.read<AuthProvider>().user!.landmark??"";
    _city.text=context.read<AuthProvider>().user!.city??"";
    _state.text=context.read<AuthProvider>().user!.state??"";
    _country.text=context.read<AuthProvider>().user!.country?.name??"";
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_getCacheData,_getLocationData]),
      builder: (context,snapshot) {
        return Consumer<AuthProvider>(
            builder:(context,state,child){
              return Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/signup2bg.jpg"),
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
                  Scaffold(
                    extendBodyBehindAppBar: true,
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      leading: IconButton(color: Colors.white,onPressed: (){
                        state.logout();
                        if(Navigator.canPop(context))Navigator.pop(context);
                        CustomLogger.debug(state.authState);
                      },icon: Icon(Icons.arrow_back_ios),),
                      elevation: 0,
                      title: Text("Personal Information",style: TextStyle(fontWeight: FontWeight.w400),),
                      iconTheme: IconThemeData(color: Colors.black),
                    ),
                    body: Form(
                      key: _formKey,
                      child: Container(
                        child: SingleChildScrollView(
                          //key: PageStorageKey<String>("try"),
                            child:Column(children: [
                              const SizedBox(height: 100,),
                              Container(
                                margin: EdgeInsets.only(left: 20,right: 20),
                                child: Column(
                                  children: [
                                    Container(
                                        height:100,
                                        width: 200,
                                        child: Image.asset("assets/images/logo/logo.png")),
                                  ],
                                ),
                              ),
                              InputField("Pan Number (optional)",
                                  _pancard,
                                  uppercase: true,
                                  leading: Icon(Icons.numbers,color: Colors.white,),
                                  validator: (text){
                                      if(text==null || text.isEmpty)return null;
                                      if(text.length!=10 || (isNumeric(text.substring(0,5))) || (!isNumeric(text.substring(5,9))) || (isNumeric(text.substring(9,10)))) return "Please enter a valid Pan Number";
                                  }
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                    prefixIcon: Icon(Icons.person,color: Colors.white,),
                                    label: Text("Kyc Type (optional)",style: TextStyle(color: Colors.white),),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                            color: Colors.blue,
                                          ),
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                  ),
                                  child: Row(
                                      children: [
                                        Expanded(
                                            child: ExpansionTile(
                                                  collapsedTextColor: Colors.white,
                                                  trailing:Text(""),
                                                  key: GlobalKey(),
                                                  title: Text(selectedKyc.title,style: TextStyle(color: Colors.white),),
                                                  children: kyctypes.map((e) => ListTile(
                                                  onTap: (){
                                                  setState(() {
                                                    _kycType.text = e.value ;
                                                    selectedKyc = e ;
                                                  });
                                                },
                                                title: Text(e.title,style: TextStyle(color: Colors.white),),
                                              )).toList(),
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              InputField("${selectedKyc.title} Number (optional)",
                                  _kycNo,
                                  validator: (text){
                                        if(text==null || text.isEmpty)return null;
                                          if(selectedKyc.value=="AD" && text.length!=12) return "Please enter a valid number";
                                          if(text.length<12) return "Please enter a valid number";
                                  }),
                              InputField("Flat / House / Building Number", _houseNo,validator: null,leading: Icon(Icons.home_filled,color: Colors.white,)),
                              InputField("Street/Sector/Village/Area", _area,leading: Icon(Icons.home_filled,color: Colors.white,)),
                              InputField("Landmark", _landmark,leading: Icon(Icons.home_filled,color: Colors.white,)),
                              InputField("Pin code", _pinCode,
                                  leading: Icon(Icons.pin_drop,color: Colors.white,),keyboardType: TextInputType.phone,validator: (text){
                                    if(text==null || text.isEmpty){
                                      return "Required Field";
                                    }
                                    if (text.length!=6){
                                      return "Please enter a 6 digit valid pincode";
                                    }
                                  }),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                                child:snapshot.connectionState == ConnectionState.waiting?Container(height: 80,):CSCPicker(
                                  flagState: CountryFlag.DISABLE,
                                  showStates: true,
                                  showCities: true,
                                  disabledDropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white,width: 1),
                                    color: Colors.transparent,
                                        ),
                                  currentCountry: _country.text,
                                  currentCity: _city.text,
                                  currentState: _state.text,
                                  selectedItemStyle: TextStyle(color: Colors.white),
                                   dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white,width: 1),
                                    color: Colors.transparent,
                                  ),
                                  onCountryChanged: (country){
                                    setState(() {
                                      _country.text = country;
                                    });
                                  },
                                  onStateChanged: (state){
                                    setState(() {
                                      _state.text = state??"" ;
                                    });
                                  },
                                  onCityChanged: (city){
                                    setState(() {
                                      _city.text=city??"";
                                    });
                                  },
                                ),
                              ),
                              if(isLoading)Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                              else SignUpButton(context,state),
                            ],)
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
        );
      }
    );
  }

  Future<void> submit(AuthProvider state)async{
    if(_formKey.currentState!.validate()){
      Map data = {
        "pan_card":_pancard.text,
        "kyc_type":_kycType.text,
        "kyc_no":_kycNo.text,
        "pin_code":_pinCode.text,
        "house_no":_houseNo.text,
        "area":_area.text,
        "landmark":_landmark.text,
        "city":_city.text,
        "state":_state.text,
        "country":selectedCountry.id,
        "vendor_reg_part":3
      } ;
      CustomLogger.debug(data);
      setState(() {
        isLoading=false;
      });
      await completeRegistration(state,data);
      state.setRegisterProgress(RegisterProgress.three);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your data has been successfully recorded.")));
    }
    else{
      setState(() {
         isLoading=false;
      });
    }
  }

  Widget SignUpButton(BuildContext context,AuthProvider state){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: (){
          state.setRegisterProgress(RegisterProgress.three);
        }, child: Text("Skip")),
        const SizedBox(width: 40,),
        ElevatedButton(
          onPressed: ()async{
            try{
              setState(() {
                isLoading = true;
              });
              await submit(state);
            }catch(e){
              setState(() {
                isLoading = false;
              });
              CustomLogger.error(e);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          child: const Text("Save and Continue"),
        )
      ],
    );
  }
  Widget InputField(String title,TextEditingController controller,{Icon leading = const Icon(Icons.person,color: Colors.white,),TextInputType keyboardType=TextInputType.text,bool hide=false,bool autocomplete=true,bool uppercase = false,String? Function(String? text)? validator}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
      child: TextFormField(
        keyboardType: keyboardType,
        textCapitalization: uppercase?TextCapitalization.characters:TextCapitalization.none,
        inputFormatters: uppercase?[
          UpperCaseTextFormatter()
        ]:null,
        obscureText: hide,
        controller: controller,
        validator:validator != null?validator:(text){
          if(text?.length==0) return "Required field";
        },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(

        prefixIcon: leading,
      label: Text(title,style: TextStyle(color: Colors.white),),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.blue,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.white,
          width: 1.0,
        ),
      ),
    )),
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
    DropDownField(title: "Current Account",value: "current"),
    DropDownField(title: "Savings Account",value: "saving"),
    DropDownField(title: "Salary Account",value: "salary"),
    DropDownField(title: "Fixed Deposit Account",value: "fixed"),
    DropDownField(title: "Recurring Deposit Account",value: "recurring"),
    DropDownField(title: "NRI Account",value: "nri"),
  ];
  TextEditingController _bankName = TextEditingController();
  TextEditingController _AccountType = TextEditingController();
  TextEditingController _AccountNo = TextEditingController();
  TextEditingController _AccountNoConfirm = TextEditingController();
  TextEditingController _IFSCNo = TextEditingController();
  TextEditingController _HolderName = TextEditingController();
  TextEditingController _BranchName = TextEditingController();
  late DropDownField selectedAccount=AccountTypes[0];
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
  Future<void> getDataFromCache()async{
    AuthProvider auth = context.read<AuthProvider>();
    selectedAccount = AccountTypes.firstWhere((element) => element.value == auth.user!.bankDetails?.accountType,orElse:()=>AccountTypes[0]);
    _AccountType.text = selectedAccount.value;
    _bankName.text = auth.user!.bankDetails?.bankName??"";
    _AccountNo.text = auth.user!.bankDetails?.accountNumber??"";
    _IFSCNo.text = auth.user!.bankDetails?.ifscNumber??"";
    _HolderName.text = auth.user!.bankDetails?.holderName??"";
    _BranchName.text = auth.user!.bankDetails?.bankName??"";
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder:(context,state,child){
          return FutureBuilder(
            future: _getCacheData,
            builder: (context, snapshot) {
              return Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/signup3bg.jpg"),
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
                  Scaffold(
                    extendBodyBehindAppBar: true,
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      leading: IconButton(color: Colors.white,onPressed: (){
                        state.setRegisterProgress(RegisterProgress.three);
                      },icon: Icon(Icons.arrow_back_ios),),
                      elevation: 0,
                      title: Text("Bank details",style: TextStyle(fontWeight: FontWeight.w400),),
                      iconTheme: IconThemeData(color: Colors.black),
                    ),
                    body: Form(
                      key: _formKey,
                      child: Container(
                        child: SingleChildScrollView(
                            child:Column(children: [
                              if(kDebugMode)TextButton(onPressed: (){
                                state.setRegisterProgress(RegisterProgress.one);
                              }, child: Text("Reset")),
                              Container(
                                margin: EdgeInsets.only(left: 20,right: 20),
                                child: Column(
                                  children: [
                                    Container(
                                        height:200,
                                        width: 200,
                                        child: Image.asset("assets/images/logo/logo.png")),
                                  ],
                                ),
                              ),
                              InputField("Bank Name", _bankName,leading: Icon(Icons.currency_rupee,color: Colors.white,)),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person,color: Colors.white),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                    label: Text("Kyc Type (optional)",style: TextStyle(color: Colors.white),),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: ExpansionTile(
                                            collapsedTextColor: Colors.white,
                                            trailing:Text(""),
                                            key: GlobalKey(),
                                            title: Text(selectedAccount.title),
                                            children: AccountTypes.map((e) => ListTile(
                                              onTap: (){
                                                setState(() {
                                                  _AccountType.text = e.value ;
                                                  selectedAccount = e ;
                                                });
                                              },
                                              title: Text(e.title,style: TextStyle(color: Colors.white),),
                                            )).toList(),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                              InputField("Account Number", _AccountNo,accountConfirm: true),
                              InputField("Re-Enter Account Number", _AccountNoConfirm,accountConfirm:true),
                              InputField("IFSC Code", _IFSCNo),
                              InputField("Holder Name", _HolderName),
                              InputField("Branch Name", _BranchName,leading: Icon(Icons.home_outlined,color: Colors.white,)),
                               Container(
                                 padding: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                                 child: Row(
                                   children: [
                                     Expanded(child: passbookPath==null?Text("Cancelled Checkbook / Passbook Front page",style: TextStyle(color: Colors.white),):Container(alignment: Alignment.centerLeft,height: 80,width: 80,child:Image.file(File(passbookPath!)))),
                                     SizedBox(width: 40,),
                                     OutlinedButton(onPressed: ()async{
                                         XFile? file =  await ImagePicker().pickImage(source: ImageSource.gallery);
                                         if(file!=null){
                                           setState(() {
                                             passbookPath = file.path;
                                           });
                                       }
                                     }, child: Text(passbookPath==null?"Choose":"Change"))
                                   ],
                                 ),
                               ),
                               if(isLoading)Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                              else
                                SignUpButton(context,state),
                            ],)
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          );
        }
    );
  }

  Future<void> submit(AuthProvider state)async{
    if(_formKey.currentState!.validate()){
      if(passbookPath==null){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Upload a cancelled Check or a passbook front page.")));
        setState(() {
          isLoading=false;
        });
        return;
      }
      Map<String,dynamic> data = {
        "bank_name":_bankName.text,
        "acc_no":_AccountNo.text,
        "ifsc_no":_IFSCNo.text,
        "holder_name":_HolderName.text,
        "branch_name":_BranchName.text,
        "acc_type":_AccountType.text,
        "img1": await MultipartFile.fromFile(passbookPath!),
        "vendor_reg_part":5
      } ;
      setState(() {
        isLoading=false;
      });
      await completeRegistration2(state,data);
      state.setRegisterProgress(RegisterProgress.five);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your data has been successfully recorded.")));
     }
    else{
      setState(() {
        isLoading=false;
      });
    }
  }

  Widget SignUpButton(BuildContext context,AuthProvider state){
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Expanded(
          child: ElevatedButton(
              onPressed: ()async{
                state.setRegisterProgress(RegisterProgress.five);
              },
              child: const Text("Skip",),
            ),
        ),
          SizedBox(width: 20,),
          Expanded(
        child:ElevatedButton(
            onPressed: ()async{
              try{
                setState(() {
                  isLoading = true;
                });
                await submit(state);
              }catch(e){
                setState(() {
                  isLoading = false;
                });
                CustomLogger.error(e);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Save and Continue"),
          )),
        ],
      ),
    );
  }

  Widget InputField(String title,TextEditingController controller,{Icon leading=const Icon(Icons.person,color: Colors.white,),bool hide=false,bool autocomplete=true,bool accountConfirm=false}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
      child: TextFormField(
        keyboardType: accountConfirm?TextInputType.number:TextInputType.text,
        obscureText: hide,
        controller: controller,
        validator: (text){
          if(text?.length==0) return "Required field";
          if(accountConfirm){
            if(_AccountNo.text.length<12 || _AccountNo.text.length>20)return "Enter Valid Account Number";
            if(_AccountNo.text!=_AccountNoConfirm.text)return "Account Numbers do not match";
          }
        },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(

            prefixIcon: leading,
            label: Text(title,style: TextStyle(color: Colors.white),),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.white,
                width: 1.0,
              ),
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
  String? panUrl,kyc,gst,vendor;
  bool prev=false;
  Map<String,String?> imgPath = {
    "Pan Card":null,
    "KYC":null,
    "GST":null,
    "Vendor":null
  };
  @override
  void initState() {
    super.initState();
    _cache = getDataFromCache();
  }
  Future getDataFromCache(){
    AuthProvider auth = Provider.of<AuthProvider>(context,listen: false);
    panUrl = auth.user!.panCardUrl;
    kyc = auth.user!.kycUrl;
    gst = auth.user!.gstUrl;
    vendor = auth.user!.vendorUrl;
    prev=true;
    return Future.value();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder:(context,state,child){
          return Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/signup4bg.jpg"),
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
              FutureBuilder(
                future: _cache,
                builder: (context,snapshot) {
                  return Scaffold(
                    extendBodyBehindAppBar: true,
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      leading: IconButton(color: Colors.white,onPressed: (){
                        state.setRegisterProgress(RegisterProgress.four);
                      },icon: Icon(Icons.arrow_back_ios),),
                      elevation: 0,
                      title: Text("KYC documents",style: TextStyle(fontWeight: FontWeight.w400),),
                      iconTheme: IconThemeData(color: Colors.black),
                    ),
                    body: Form(
                      key: _formKey,
                      child: Container(
                        child: SingleChildScrollView(
                            child:Column(children: [
                              Container(
                                margin: EdgeInsets.only(left: 20,right: 20),
                                child: Column(
                                  children: [
                                    Container(
                                        height:200,
                                        width: 200,
                                        child: Image.asset("assets/images/logo/logo.png")),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 80),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Pan Card (optional)",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(height: 100,width: 100,
                                          child:panUrl!=null?
                                            CachedNetworkImage(imageUrl: panUrl!,
                                              placeholder: (context,url){
                                              return Container(
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(),
                                              );
                                              },
                                              errorWidget: (context,url,err){
                                              return Icon(Icons.file_copy,size: 60,color: Colors.white,);
                                            },)
                                            :
                                        imgPath["Pan Card"]==null?Icon(Icons.file_copy,size: 60,color: Colors.white,):Image.file(File(imgPath["Pan Card"]!)),),
                                        ElevatedButton(onPressed: ()async{
                                          XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                         if(file!=null){
                                           int size = await file!.length()~/1024;
                                           if(size>2048){
                                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image too big. Please select an image below 2mb")));
                                           }
                                           else{
                                             setState(() {
                                               imgPath["Pan Card"]=file?.path;
                                               panUrl=null;
                                             });
                                           }
                                         }
                                        }, child: Text("Choose File")),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 80),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("GST (optional)",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(height: 100,width: 100,
                                          child:
                                          gst!=null?
                                          CachedNetworkImage(
                                            imageUrl: gst!,
                                            placeholder: (context,url){
                                              return Container(
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(),
                                              );
                                            },
                                            errorWidget: (context,str,err){
                                            return Icon(Icons.file_copy,size: 60,color: Colors.white,);
                                          },)
                                              :
                                          imgPath["GST"]==null?Icon(Icons.file_copy,size: 60,color: Colors.white,):Image.file(File(imgPath["GST"]!)),),
                                        ElevatedButton(onPressed: ()async{
                                         FilePickerResult? file = await FilePicker.platform.pickFiles(allowedExtensions: ["pdf","jpg","jpeg"],type: FileType.custom);
                                          if(file!=null){
                                            int size = await file.files.single.size~/1024;
                                            if(size>2048){
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image too big. Please select an image below 2mb")));
                                            }
                                            else{
                                              setState(() {
                                                imgPath["GST"]=file.files.single.path;
                                                gst=null;
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
                                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 80),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("KYC (optional)",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(height: 100,width: 100,
                                          child:
                                          kyc!=null?
                                          CachedNetworkImage(
                                            imageUrl: kyc!,
                                            placeholder: (context,url){
                                              return Container(
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(),
                                              );
                                            },
                                            errorWidget: (context,str,err){
                                            return Icon(Icons.file_copy,size: 60,color: Colors.white,);
                                          },)
                                              :
                                          imgPath["KYC"]==null?Icon(Icons.file_copy,size: 60,color: Colors.white,):Image.file(File(imgPath["KYC"]!)),),
                                        ElevatedButton(onPressed: ()async{
                                          XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                          if(file!=null){
                                            int size = await file!.length()~/1024;
                                            if(size>2048){
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image too big. Please select an image below 2mb")));
                                            }
                                            else{
                                              setState(() {
                                                imgPath["KYC"]=file?.path;
                                                kyc=null;
                                              });
                                            }
                                          }
                                        }, child: Text("Choose File")),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 80),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Vendor Picture (optional)",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(height: 100,width: 100,
                                          child:
                                          vendor!=null?
                                          CachedNetworkImage(imageUrl: vendor!,
                                            placeholder: (context,url){
                                              return Container(
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(),
                                              );
                                            },
                                            errorWidget: (context,str,err){
                                            return Icon(Icons.file_copy,size: 60,color: Colors.white,);
                                          },)
                                              :
                                          imgPath["Vendor"]==null?Icon(Icons.file_copy,size: 60,color: Colors.white,):Image.file(File(imgPath["Vendor"]!)),),
                                        ElevatedButton(onPressed: ()async{
                                          XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                          if(file!=null){
                                            int size = await file.length()~/1024;
                                            if(size>2048){
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image too big. Please select an image below 2mb")));
                                            }
                                            else{
                                              setState(() {
                                                imgPath["Vendor"]=file.path;
                                                vendor=null;
                                              });
                                            }
                                          }
                                        }, child: Text("Choose File")),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if(isLoading)Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                              else SignUpButton(context,state),
                            ],)
                        ),
                      ),
                    ),
                  );
                }
              ),
            ],
          );
        }
    );
  }

  Future<void> submit(AuthProvider state)async{
    Map<String,dynamic> data = {
      "vendor_reg_part":6,
    };
      setState(() {
        isLoading=true;
      });
      data["img1"]=imgPath["Pan Card"]==null?null:await MultipartFile.fromFile(imgPath["Pan Card"]!);
    data["img2"]=imgPath["KYC"]==null?null:await MultipartFile.fromFile(imgPath["KYC"]!);
    data["img3"]=imgPath["Vendor"]==null?null:await MultipartFile.fromFile(imgPath["Vendor"]!);
    data["img4"]=imgPath["GST"]==null?null:await MultipartFile.fromFile(imgPath["GST"]!);
    CustomLogger.debug(data);
    await completeRegistration3(state,data);
      state.setRegisterProgress(RegisterProgress.six);
        setState(() {
        isLoading=false;
      });

  }

  Widget SignUpButton(BuildContext context,AuthProvider state){
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: ()async{
                state.setRegisterProgress(RegisterProgress.six);
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
              ),
              child: const Text("Skip"),
            ),
          ),
          const SizedBox(width: 40,),
          Expanded(
            child: ElevatedButton(
              onPressed: ()async{
                try{
                  await submit(state);
                }catch(e){
                  setState(() {
                    isLoading = false;
                  });
                  CustomLogger.error(e);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
              ),
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
  String serviceOption = "Select Service",serviceId="";

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
  late DropDownField selectedKyc=DropDownField(title: "Aadhar",value: "AD");
  late Future _getCacheData;
  Future _getLocation = Future.value({});
  List<AddProductPhoto> productImages = [];
  String? driverImage,drivingLicenseImage;
  String? videoPath;
  List<String> dataKeys = ["category_id","service_id","service_desc","material_desc","office_pincode","office_house_no","office_area","office_country","office_landmark","office_city","office_state","price","driver_name","driver_mobile_no","driver_kyc_type","dricer_kyc_no","driver_licence_no","driver_pincode","driver_house_no","driver_area","driver_landmark","driver_city","driver_state","gst_no"];

  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar",value: "AD"),
    DropDownField(title: "Voter Id",value: "VO"),
    DropDownField(title: "Passport",value: "PA"),
    DropDownField(title: "Driving License",value: "DL"),
    DropDownField(title: "Other Govt. Id",value: "OT"),
  ];

  late Country selectedOfficeCountry;
  Future<void> getDataFromCache()async{
    AuthProvider auth = context.read<AuthProvider>();
    selectedOfficeCountry = Country(id: "101", name: "India");
    Map country = {"id": "101", "name": "India"};
    try{
    country = DefaultCountries.where((element) => element["id"]==auth.user!.country?.id).first;
    if (!country.containsKey("id")) {
      country = {"id": "101", "name": "India"};
    }}
    catch(e){

    }
    selectedOfficeCountry = Country(id:country["id"], name:country["name"]);
    _officePinCode.text =  auth.user!.officeZip??"";
    _officeNo.text =  auth.user!.officeNumber??"";
    _officePhone.text =  auth.user!.officePhone??"";
    _officeArea.text =  auth.user!.officeArea ??"";
    _officeLandmark.text =  auth.user!.officeLandmark??"";
    _officeCity.text =  auth.user!.officeCity??"";
    _officeState.text =  auth.user!.officeState??"";
    _officeCountry.text = selectedOfficeCountry.id;
    _GST.text = auth.user!.gstNumber??"";
      try{
        _driverKycType.text= kyctypes
            .firstWhere((element) => element.value == auth.user!.service?.driverDetails.kycType).title??"";
      }
      catch(e){

      }
     _serviceDescription.text = auth.user!.service?.serviceDescription??"";
     _price.text = auth.user!.service?.price ?? "";
     _materialDescription.text = auth.user!.service?.materialDescription??"";
     _driverName.text = auth.user!.service?.driverDetails.name??"";
     _driverMob.text = auth.user!.service?.driverDetails.mobileNumber??"";
     _driverKycNo.text = auth.user!.service?.driverDetails.kycNumber??"";
     _driverpinCode.text = auth.user!.service?.driverDetails.pinCode??"";
     _driverhouseNo.text = auth.user!.service?.driverDetails.houseNumber??"";
     _driverArea.text = auth.user!.service?.driverDetails.area??"";
     _driverLandmark.text = auth.user!.service?.driverDetails.landmark??"";
     _driverCity.text = auth.user!.service?.driverDetails.landmark??"";
     _driverState.text = auth.user!.service?.driverDetails.state??"";
     _officePinCode.addListener(() {
       if(_officePinCode.text.length>=6){
         setState(() {
           _getLocation=_getLocationfromPinCode();
         });
       }
     });
  }
  Future _getLocationfromPinCode()async{
    var data =await getCountryStateCityfromZip(_officePinCode.text);
    setState(() {
      _officeCountry.text=data["country"]!;
      _officeState.text=data["state"]!;
      _officeCity.text=data["city"]!;
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
        ChangeNotifierProvider(create: (_)=>DropDownOptionProvider(auth: Provider.of<AuthProvider>(context)),),
        ChangeNotifierProvider(create: (_)=>MapProvider())
      ],
      child: Consumer2<DropDownOptionProvider,AuthProvider>(
          builder:(context,state,regState,child){
            if(regState.isLoading || state.isLoading){
              return LoadingWidget();
            }

            return FutureBuilder(
              future: Future.wait([_getCacheData,_getLocation]),
              builder: (context, snapshot) {
                return Consumer<MapProvider>(
                  builder:(context,mapState,child)=>Stack(
                    children: [Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/signup1bg.jpg"),
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
                      Scaffold(
                        extendBodyBehindAppBar: true,
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          leading: IconButton(color: Colors.white,onPressed: (){
                            regState.setRegisterProgress(RegisterProgress.two);
                          },icon: Icon(Icons.arrow_back_ios),),
                          elevation: 0,
                          title: Text("Office Details",style: TextStyle(fontWeight: FontWeight.w400),),
                          iconTheme: IconThemeData(color: Colors.black),
                        ),
                        body: Form(
                          key: _formKey,
                          child: Container(
                            padding: EdgeInsets.all(11),
                            height: double.infinity,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Column(
                                  children:<Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 20,right: 20),
                                      child: Column(
                                        children: [
                                          Container(
                                              height:200,
                                              width: 200,
                                              child: Image.asset("assets/images/logo/logo.png")),
                                        ],
                                      ),
                                    ),
                                    InputField("GST Number", _GST,isCapital: true,required:false,leading: Icon(Icons.numbers,color: Colors.white,)),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      margin: EdgeInsets.only(top: 20),
                                      child: IntlPhoneField(
                                        initialCountryCode: "IN",
                                        showCountryFlag: false,
                                        dropdownIcon: const Icon(Icons.arrow_drop_down,color: Colors.white,),
                                        style: TextStyle(color: Colors.white),
                                        dropdownTextStyle: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          label: Text("Phone Number",
                                            style: TextStyle(color: Colors.white),),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: Colors.blue,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        validator: (text){
                                          if(text==null || text.completeNumber.isEmpty){
                                            return "Required field";
                                          }
                                          if(text.completeNumber.length<12 || text.completeNumber.length>15){
                                            return "Please enter a valid number";
                                          }
                                        },
                                        onChanged: (number){
                                          _officePhone.text = number.completeNumber;
                                        },
                                      ),
                                    ),
                                    InputField("Flat / House / Building Number", _officeNo,leading: Icon(Icons.home_filled,color: Colors.white,)),
                                    InputField("Street/Sector/Village/Area", _officeArea,leading: Icon(Icons.home_filled,color: Colors.white,)),
                                    InputField("Landmark", _officeLandmark,leading: Icon(Icons.home_filled,color: Colors.white,)),
                                    InputField("PinCode", _officePinCode,leading: Icon(Icons.pin_drop,color: Colors.white,),isPin:true),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                                      child: snapshot.connectionState==ConnectionState.waiting?Container(height: 80,):CSCPicker(
                                        showStates: true,
                                        showCities: true,
                                        disabledDropdownDecoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white,width: 1),
                                          color: Colors.transparent,
                                        ),
                                        currentCountry: selectedOfficeCountry.name,
                                        currentCity: _officeCity.text,
                                        currentState: _officeState.text,
                                        selectedItemStyle: TextStyle(color: Colors.white),
                                        dropdownDecoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white,width: 1),
                                          color: Colors.transparent,
                                        ),
                                        onCountryChanged: (country){
                                          setState(() {
                                            _officeCountry.text = country;
                                          });
                                        },
                                        onStateChanged: (state){
                                          setState(() {
                                            _officeState.text = state??"" ;
                                          });
                                        },
                                        onCityChanged: (city){
                                          setState(() {
                                            _officeCity.text=city??"";
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                      child: Text("Service details",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                      child: ExpansionTile(
                                        collapsedShape: OutlineInputBorder(borderSide: BorderSide(width: 1,color: Colors.white),borderRadius: BorderRadius.circular(5)),
                                        shape: OutlineInputBorder(borderSide: BorderSide(width: 1,color: Colors.white),borderRadius: BorderRadius.circular(5)),
                                        textColor: Colors.white,
                                        iconColor: Colors.white,
                                        collapsedTextColor: Colors.white,
                                        key: GlobalKey(),
                                        title: Text(serviceOption,style: TextStyle(color: Colors.white),),
                                        children: state.options!.serviceOptions.map(
                                              (e) => ListTile(title: Text(e.service,style: TextStyle(color: Colors.white),),onTap: (){
                                            setState(() {
                                              serviceOption = e.service ;
                                              serviceId = e.id ;
                                            });
                                          },),).toList(),
                                      ),
                                    ),
                                    InputField("Service Description", _serviceDescription,leading: Icon(Icons.description,color: Colors.white,)),
                                    InputField("Material Description", _materialDescription,leading: Icon(Icons.description_outlined,color: Colors.white,)),
                                    InputField("Price", _price,isPrice: true,leading: Icon(Icons.currency_rupee,color: Colors.white,)),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Product photos. Max 5",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                          ElevatedButton(onPressed: ()async{
                                            if(productImages.length>=5){
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Maximum 5 photos allowed")));
                                              return;
                                            }
                                            List<XFile?> images = await ImagePicker().pickMultiImage();
                                            setState(() {
                                              if(images.length>5){
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Maximum 5 photos allowed")));
                                              }
                                              images.forEach((element) {
                                                if(productImages.length==5)return;
                                                productImages.add(AddProductPhoto(
                                                    filePath: element?.path,
                                                    id: productImages.length, onDelete: (id){
                                                  setState(() {
                                                    productImages.removeWhere((element) => element.id == id);
                                                  });
                                                }));
                                              });
                                            });
                                          }, child:const Text("Add"))
                                        ],
                                      ),
                                    ),
                                    ...productImages,
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                      child: Text("Add a video",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 25),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: 80,
                                            height: 60,
                                            child: videoPath!=null?Container(child: Text("Video Selected"),):Container(color: Colors.grey,),),
                                          Container(child: ElevatedButton(child:const Text("Choose"),onPressed: ()async{
                                            XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
                                            setState(() {
                                              videoPath = video?.path;
                                            });
                                          },),)
                                        ],
                                      ),
                                    ),
                                    if(serviceOption.toLowerCase().endsWith("car"))
                                      Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                            child: Text("Driver details",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
                                          ),
                                          InputField("Name", _driverName),
                                          Container(
                                            padding: EdgeInsets.only(left: 20,right: 20,top: 30),
                                            child: IntlPhoneField(
                                              initialCountryCode: "IN",
                                              showCountryFlag: false,
                                              dropdownIcon: const Icon(Icons.arrow_drop_down,color: Colors.white,),
                                              style: TextStyle(color: Colors.white),
                                              dropdownTextStyle: TextStyle(color: Colors.white),
                                              decoration: InputDecoration(
                                                label: Text("Phone Number",
                                                  style: TextStyle(color: Colors.white),),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ),
                                              validator: (text){
                                                if(text==null || text.completeNumber.isEmpty){
                                                  return "Required field";
                                                }
                                                if(text.completeNumber.length<12 || text.completeNumber.length>15){
                                                  return "Please enter a valid number";
                                                }
                                              },
                                              onChanged: (number){
                                                _driverMob.text = number.completeNumber;
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                  prefixIcon: Icon(Icons.person,color: Colors.white),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                                label: Text("Kyc Type",style: TextStyle(color: Colors.white),),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: ExpansionTile(
                                                        trailing:Text(""),
                                                        key: GlobalKey(),
                                                        title: Text(selectedKyc.title,style: TextStyle(color: Colors.white),),
                                                        children: kyctypes.map((e) => ListTile(
                                                          onTap: (){
                                                            setState(() {
                                                              _driverKycType.text = e.value ;
                                                              selectedKyc = e ;
                                                            });
                                                          },
                                                          title: Text(e.title,style: TextStyle(color: Colors.white),),
                                                        )).toList(),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                          InputField("${selectedKyc.title} Number", _driverKycNo,isAadhar: true),
                                          InputField("License", _driverLicense),
                                          InputField("House Number", _driverhouseNo),
                                          InputField("Street/Sector/Village/Area", _driverArea),
                                          InputField("Landmark", _driverLandmark),
                                          InputField("City", _driverCity),
                                          InputField("PinCode", _driverpinCode,isPin: true),
                                          InputField("State", _driverState),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                            child: Text("Choose Driver Image",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 25),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 80,
                                                  height: 60,
                                                  child: driverImage!=null?Image.file(File(driverImage!)):Container(color: Colors.grey,),),
                                                Container(child: ElevatedButton(child:const Text("Choose"),onPressed: ()async{
                                                  XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                                  setState(() {
                                                    driverImage = image?.path;
                                                  });
                                                },),)
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                            child: Text("Choose Driving License Image",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 25),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 80,
                                                  height: 60,
                                                  child: drivingLicenseImage!=null?Image.file(File(drivingLicenseImage!)):Container(color: Colors.grey,),),
                                                Container(child: ElevatedButton(child:const Text("Choose"),onPressed: ()async{
                                                  XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                                  setState(() {
                                                    drivingLicenseImage = image?.path;
                                                  });
                                                },),)
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    if(isLoading)
                                      Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                                    else
                                      CreateButton(context, regState),
                                  ]
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            );
          }
      ),
    );
  }
  Widget CreateButton(BuildContext context,AuthProvider state){
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: (){
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
  Widget InputField(String title,TextEditingController controller,{Icon leading=const Icon(Icons.person,color: Colors.white,),bool required=true,MapProvider? state,bool isAadhar=false,bool hide=false,bool autoComplete = false,bool validatePhone=false,bool isCapital= false,bool isPin=false,bool isPrice=false}){
    if(validatePhone){
      if(!controller.text.startsWith("+91"))
        controller.text="+91"+controller.text;
    }
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
      child: TextFormField(
        keyboardType: validatePhone || isPin || isPrice?TextInputType.phone:TextInputType.text,
        textCapitalization: isCapital?TextCapitalization.characters:TextCapitalization.none,
        obscureText: hide,
        controller: controller,
        onChanged: autoComplete?(text){
          state!.getLocations(text);
          setState(() {
            showLocationList=true;
          });
        }:null,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(

            prefixIcon: leading,
            label: Text(title,style: TextStyle(color: Colors.white),),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.white,
                width: 1.0,
              ),
            ),
          ),
        validator: required?(text){
          if(text==null || text.length==0){
            return "Required field";
          }
          if(isAadhar){
            if(text.length<12){
              return "Please enter a valid Aadhar number";
            }
          }
          if(validatePhone){
            if(text.length<10 || text.length>15){
              return "Please enter a valid phone number";
            }
          }
          if(isPin){
            if(text.length!=6){
              return "Please enter a 6 digit pin code";
            }
          }
        }:null,
      ),
    );
  }
  void createService(AuthProvider state)async{
    if(_formKey.currentState!.validate()){
      if(serviceId.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a service")));
        return;
      }
      Map<String,dynamic> data = {
        "service_id":serviceId,
        "service_desc":_serviceDescription.text,
        "material_desc":_materialDescription.text,
        "office_pincode":_officePinCode.text,
        "office_house_no":_officeNo.text,
        "office_mobile":_officePhone.text,
        "office_area":_officeArea.text,
        "office_landmark":_officeLandmark.text,
        "office_city":_officeCity.text,
        "office_state":_officeState.text,
        "office_country":selectedOfficeCountry.id,
        "gst_no":_GST.text,
        "price":_price.text,//
        "driver_name":_driverName.text,
        "driver_mobile_no":_driverMob.text,
        "driver_kyc_type":_driverKycType.text,
        "dricer_kyc_no":_driverKycNo.text,
        "driver_licence_no":_driverLicense.text,
        "driver_pincode":_driverpinCode.text,
        "driver_house_no":_driverhouseNo.text,
        "driver_area":_driverArea.text,
        "driver_landmark":_driverLandmark.text,
        "driver_city":_driverCity.text,
        "driver_state":_driverState.text,
        "vendor_reg_part":4,
        "img6":driverImage==null?null:await MultipartFile.fromFile(driverImage!),
        "img5":drivingLicenseImage==null?null:await MultipartFile.fromFile(drivingLicenseImage!),
        "video":videoPath==null?null:await MultipartFile.fromFile(videoPath!)
      };
      for(int i = 0;i<productImages.length;i++){
        data['pmg${i+1}']=productImages[i].filePath==null?null:await MultipartFile.fromFile(productImages[i].filePath!);
      }
      CustomLogger.debug(data);
      try{
        await completeRegistrationIntermediate(state, data);
        state.setRegisterProgress(RegisterProgress.four);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service created successfully")));
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
  Future<void> submit(AuthProvider auth)async{
      try{
        await completeRegistrationTerms(auth);
      }
      catch(e){
        CustomLogger.error(e);
      }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context,registerState,child) {
        return Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/signup1bg.jpg"),
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
            Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(color: Colors.white,onPressed: (){
                  registerState.setRegisterProgress(RegisterProgress.five);
                },icon: Icon(Icons.arrow_back_ios),),
                elevation: 0,
                title: Text("Terms and Conditions",style: TextStyle(fontWeight: FontWeight.w400),),
                iconTheme: IconThemeData(color: Colors.black),
              ),
              body: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 20,right: 20),
                        child: Column(
                          children: [
                            Container(
                                height:200,
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
                        data: ThemeData(
                          unselectedWidgetColor: Colors.white
                        ),
                        child: CheckboxListTile(
                          checkColor: Colors.white,
                          checkboxShape: RoundedRectangleBorder(side: BorderSide(color: Colors.white,width: 0.5)),
                          value: _agreedToTerms,
                          onChanged: _toggleTermsAgreement,
                          title: Text('I agree to the terms and conditions',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: !_agreedToTerms ? null : ()async{
                          await submit(registerState);
                          registerState.setRegisterProgress(RegisterProgress.completed);
                          registerState.clear();
                          if(Navigator.canPop(context)){
                            Navigator.popUntil(context,(route)=>route.isFirst);
                          }else{
                            Navigator.pushReplacementNamed(context, MainPage.routeName,arguments: true);
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
      }
    );
  }

}

