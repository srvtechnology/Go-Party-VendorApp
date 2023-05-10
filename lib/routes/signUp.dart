import 'dart:math';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/loading.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/RegisterProvider.dart';
import 'package:utsavlife/core/provider/mapProvider.dart';
import 'package:utsavlife/core/repo/auth.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/core/utils/textformatters.dart';
import 'package:utsavlife/routes/mainpage.dart';

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
    return  ListenableProvider(
        create: (_)=>RegisterProvider(auth: Provider.of<AuthProvider>(context)),
        child:Consumer<RegisterProvider>(
          builder:(context,state,child){
            if(state.isLoading){
              return LoadingWidget();
            }
            if(state.registerProgress == RegisterProgress.two){
              return SignUp2();
            }
            if(state.registerProgress == RegisterProgress.three){
              return SignUpIntermediate();
            }
            if(state.registerProgress == RegisterProgress.four){
              return SignUp3();
            }
            if(state.registerProgress == RegisterProgress.five){
              return SignUp4();
            }
            return SignUp1();
          })
    );
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
  late List<TextEditingController> _controllers;
  bool showLocationList = false ;
  bool isLoading = false;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableProvider(create: (_)=>MapProvider(),
        child: Consumer2<MapProvider,RegisterProvider>(
          builder:(context,mapState,registerState,child)=>GestureDetector(
            onTap: (){
              FocusManager.instance.primaryFocus!.unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                 backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
              ),
              body: Form(
                key: _formKey,
                child: Container(
                  child: SingleChildScrollView(
                      child:Column(children: [
                        SizedBox(
                          height: 10.h,
                          width: 20.w,
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
                        CustomInputField("Full Name", _name),
                        CustomInputField("Email", _email),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: InputField(title:"Password",controller: _password,isPassword:true,obscureText: true,leading: Icon(Icons.person),)),
                        CustomInputField("Mobile number", _mobileNo,validatePhone:true),
                        CustomInputField("Address", _address,autocomplete:true,state: mapState),
                        if(showLocationList&&mapState.locations.isNotEmpty)
                          ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,itemCount: min(6, mapState.locations.length),itemBuilder: (context,index)=>ListTile(leading: Icon(Icons.location_on),title: Text(mapState.locations[index]),onTap: (){
                            _address.text = mapState.locations[index];
                            setState(() {
                              showLocationList=false;
                            });
                          },)),
                        if(isLoading)Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                        else SignUpButton(context,mapState,registerState),
                      ],)
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> submit(RegisterProvider registerState,MapProvider mapState)async{
    if(_formKey.currentState!.validate()){
      //await mapState.getLatLong(_address.text);
      //CustomLogger.debug(mapState.coordinates);
      Map data = {
        "name":_name.text.toString(),
        "email":_email.text,
        "password":_password.text,
        "mobile":_mobileNo.text,
        "address_address":_address.text,
        "distance_cover":0,
        "address_latitude":0,//mapState.coordinates.latitude,
        "address_longitude":0,//mapState.coordinates.longitude
      } ;
      CustomLogger.debug(data);
      await signUpMain(data);
      registerState.setEmailPassword(email: _email.text, password: _password.text);
      await registerState.getAuthToken();
      registerState.setRegisterProgress(RegisterProgress.two);
    }
    else{
      setState(() {
        isLoading=false;
      });
    }
  }
  Widget SignUpButton(BuildContext context,MapProvider mapState,RegisterProvider registerState){
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: ()async{
              registerState.setRegisterProgress(RegisterProgress.completed);
              if(Navigator.canPop(context)){
                Navigator.pop(context);
              }
              else{
                Navigator.pushReplacementNamed(context, MainPage.routeName);
              }
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Discard",style: TextStyle(color: Colors.grey),),
          ),
          OutlinedButton(
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
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Save&Next"),
          ),
        ],
      ),
    );
  }
  Widget CustomInputField(String title,TextEditingController controller,{bool hide=false,bool autocomplete=true,MapProvider? state,validatePhone=false}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
      child: TextFormField(
        obscureText: hide,
        controller: controller,
        validator: (text){
          if(text?.length==0) return "Required field";
          if(validatePhone){
            if(text!=null && (text.length<10 || text.length>12)){
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
            prefixIcon: Icon(Icons.person),
            labelText: title,border: const OutlineInputBorder()),
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
    DropDownField(title: "Aadhar Card",value: "AD"),
    DropDownField(title: "Voter Id",value: "VO"),
    DropDownField(title: "Passport",value: "PA"),
    DropDownField(title: "Driving License",value: "DL"),
    DropDownField(title: "Other Govt. Id",value: "OT"),
  ];
  TextEditingController _pancard = TextEditingController();
  TextEditingController _kycType = TextEditingController();
  TextEditingController _kycNo = TextEditingController();
  TextEditingController _pinCode = TextEditingController();
  TextEditingController _houseNo = TextEditingController();
  TextEditingController _area = TextEditingController();
  TextEditingController _landmark = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _state = TextEditingController();
  late RegisterCache cache;
  late DropDownField selectedKyc=kyctypes[0];
  bool isLoading = false;
  late Future _getCacheData ;
  List<String> dataKeys = [
    "pan_card","kyc_type","kyc_no","pin_code","house_no","area","landmark","city","state"
  ];

  @override
  void initState() {
    super.initState();
    cache = RegisterCache(fields: dataKeys);
    _getCacheData = getDataFromCache();
  }
  Future<void> getDataFromCache()async{
    await cache.getData(dataKeys);
    selectedKyc = kyctypes.firstWhere((element) => element.value == cache.data["kyc_type"],orElse: ()=>kyctypes[0]);
    _kycType.text = selectedKyc.value;
    _pancard.text=cache.data["pan_card"]??"";
    _kycNo.text=cache.data["kyc_no"]??"";
    _pinCode.text=cache.data["pin_code"]??"";
    _houseNo.text=cache.data["house_no"]??"";
    _area.text=cache.data["area"]??"";
    _landmark.text=cache.data["landmark"]??"";
    _city.text=cache.data["city"]??"";
    _state.text=cache.data["state"]??"";

  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCacheData,
      builder: (context, snapshot) {
        return Consumer<RegisterProvider>(
            builder:(context,state,child){
              return Scaffold(
                appBar: AppBar(automaticallyImplyLeading: false,),
                body: Form(
                  key: _formKey,
                  child: Container(
                    child: SingleChildScrollView(
                        child:Column(children: [
                          SizedBox(
                            height: 10.h,
                            width: 20.w,
                            child: Image.asset("assets/images/logo/logo-nav.png"),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin:const EdgeInsets.symmetric(vertical: 10),
                            child:const Text("Provide your details below"),
                          ),
                          InputField("Pan Card", _pancard,uppercase: true),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 45),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Kyc Type"),
                                DropdownButton(
                                  value: selectedKyc,
                                  items: kyctypes.map((e)=>DropdownMenuItem(child: Text(e.title),value: e,)).toList(),
                                  onChanged: (_){
                                    setState(() {
                                      _kycType.text = _!.value ;
                                      selectedKyc = _ ;
                                    });
                                  },

                                ),
                              ],
                            ),
                          ),
                          InputField("${selectedKyc.title} Number", _kycNo),
                          InputField("Pin code", _pinCode),
                          InputField("House number", _houseNo),
                          InputField("Area", _area),
                          InputField("Landmark", _landmark),
                          InputField("City", _city),
                          InputField("State", _state),
                          if(isLoading)Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                          else SignUpButton(context,state),
                        ],)
                    ),
                  ),
                ),
              );
            }
        );
      }
    );
  }

  Future<void> submit(RegisterProvider state)async{
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
        "state":_state.text
      } ;
      setState(() {
        isLoading=false;
      });
      await completeRegistration(state,data);
      cache.setData(data);
      state.setRegisterProgress(RegisterProgress.three);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your data has been successfully recorded.")));
    }
    else{
      setState(() {
        getDataFromCache();
        isLoading=false;
      });
    }
  }

  Widget SignUpButton(BuildContext context,RegisterProvider state){
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlinedButton(
            onPressed: ()async{
              state.setRegisterProgress(RegisterProgress.one);
              },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Discard"),
          ),
          OutlinedButton(
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
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Save&Next"),
          ),
        ],
      ),
    );
  }

  Widget InputField(String title,TextEditingController controller,{bool hide=false,bool autocomplete=true,bool uppercase = false}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
      child: TextFormField(
        textCapitalization: uppercase?TextCapitalization.characters:TextCapitalization.none,
        inputFormatters: uppercase?[
          UpperCaseTextFormatter()
        ]:null,
        obscureText: hide,
        controller: controller,
        validator: (text){
          if(text?.length==0) return "Required field";
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            labelText: title,border: const OutlineInputBorder()),
      ),
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
  bool isLoading = false;
  late RegisterCache cache;
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
    cache = RegisterCache(fields: dataKeys);
    _getCacheData = getDataFromCache();
  }
  Future<void> getDataFromCache()async{
    cache.getData(dataKeys);
    selectedAccount = AccountTypes.firstWhere((element) => element.value == cache.data["acc_type"],orElse:()=>AccountTypes[0]);
    _AccountType.text = selectedAccount.value;
    _bankName.text = cache.data["bank_name"];
    _AccountNo.text = cache.data["acc_no"];
    _IFSCNo.text = cache.data["ifsc_no"];
    _HolderName.text = cache.data["holder_name"];
    _BranchName.text = cache.data["branch_name"];

  }
  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
        builder:(context,state,child){
          return FutureBuilder(
            future: _getCacheData,
            builder: (context, snapshot) {
              return Scaffold(
                appBar: AppBar(automaticallyImplyLeading: false,),
                body: Form(
                  key: _formKey,
                  child: Container(
                    child: SingleChildScrollView(
                        child:Column(children: [
                          if(kDebugMode)TextButton(onPressed: (){
                            state.setRegisterProgress(RegisterProgress.one);
                          }, child: Text("Reset")),
                          SizedBox(
                            height: 10.h,
                            width: 20.w,
                            child: Image.asset("assets/images/logo/logo-nav.png"),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin:const EdgeInsets.symmetric(vertical: 10),
                            child:const Text("Provide your details below"),
                          ),
                          InputField("Bank Name", _bankName),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 45),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Account Type"),
                                SizedBox(width: 20,),
                                Expanded(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    value: selectedAccount,
                                    items: AccountTypes.map((e)=>DropdownMenuItem(child: Text(e.title),value: e,)).toList(),
                                    onChanged: (_){
                                      setState(() {
                                        _AccountType.text = _!.value ;
                                        selectedAccount = _ ;
                                      });
                                    },

                                  ),
                                ),
                              ],
                            ),
                          ),
                          InputField("Account Number", _AccountNo),
                          InputField("Account Number (Again)", _AccountNoConfirm,accountConfirm:true),
                          InputField("IFSC Code", _IFSCNo),
                          InputField("Holder Name", _HolderName),
                          InputField("Branch Name", _BranchName),
                           if(isLoading)Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                          else SignUpButton(context,state),
                        ],)
                    ),
                  ),
                ),
              );
            }
          );
        }
    );
  }

  Future<void> submit(RegisterProvider state)async{
    if(_formKey.currentState!.validate()){
      Map data = {
        "bank_name":_bankName.text,
        "acc_no":_AccountNo.text,
        "ifsc_no":_IFSCNo.text,
        "holder_name":_HolderName.text,
        "branch_name":_BranchName.text,
        "acc_type":_AccountType.text,
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

  Widget SignUpButton(BuildContext context,RegisterProvider state){
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: (){
                 state.setRegisterProgress(RegisterProgress.three);
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Previous",style:TextStyle(color:Colors.red)),
          ),OutlinedButton(
            onPressed: ()async{
              state.setRegisterProgress(RegisterProgress.five);
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Skip",style: TextStyle(color: Colors.grey),),
          ),
          OutlinedButton(
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
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Save&Next"),
          ),
        ],
      ),
    );
  }

  Widget InputField(String title,TextEditingController controller,{bool hide=false,bool autocomplete=true,bool accountConfirm=false}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
      child: TextFormField(
        obscureText: hide,
        controller: controller,
        validator: (text){
          if(text?.length==0) return "Required field";
          if(accountConfirm){
            if(_AccountNo.text!=controller.text)return "Account Numbers do not match";
          }
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            labelText: title,border: const OutlineInputBorder()),
      ),
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
  Map<String,String?> imgPath = {
    "Pan Card":null,
    "KYC":null,
    "GST":null,
    "Vendor":null
  };

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
        builder:(context,state,child){
          return Scaffold(
            appBar: AppBar(automaticallyImplyLeading: false,),
            body: Form(
              key: _formKey,
              child: Container(
                child: SingleChildScrollView(
                    child:Column(children: [
                      SizedBox(
                        height: 10.h,
                        width: 20.w,
                        child: Image.asset("assets/images/logo/logo-nav.png"),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin:const EdgeInsets.symmetric(vertical: 10),
                        child:const Text("Provide your details below"),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10,horizontal: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pan Card",style: TextStyle(fontWeight: FontWeight.bold),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(height: 100,width: 60,child: imgPath["Pan Card"]==null?Icon(Icons.file_copy,size: 60,):Image.file(File(imgPath["Pan Card"]!)),),
                                TextButton(onPressed: ()async{
                                  XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                 if(file!=null){
                                   int size = await file!.length()~/1024;
                                   if(size>2048){
                                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image too big. Please select an image below 2mb")));
                                   }
                                   else{
                                     setState(() {
                                       imgPath["Pan Card"]=file?.path;
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
                            Text("GST",style: TextStyle(fontWeight: FontWeight.bold),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(height: 100,width: 60,child: imgPath["GST"]==null?Icon(Icons.file_copy,size: 60,):Image.file(File(imgPath["GST"]!)),),
                                TextButton(onPressed: ()async{
                                  XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if(file!=null){
                                    int size = await file!.length()~/1024;
                                    if(size>2048){
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image too big. Please select an image below 2mb")));
                                    }
                                    else{
                                      setState(() {
                                        imgPath["GST"]=file?.path;
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
                            Text("KYC",style: TextStyle(fontWeight: FontWeight.bold),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(height: 100,width: 100,child: imgPath["KYC"]==null?Icon(Icons.file_copy,size: 60,):Image.file(File(imgPath["KYC"]!)),),
                                TextButton(onPressed: ()async{
                                  XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if(file!=null){
                                    int size = await file!.length()~/1024;
                                    if(size>2048){
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image too big. Please select an image below 2mb")));
                                    }
                                    else{
                                      setState(() {
                                        imgPath["KYC"]=file?.path;
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
                            Text("Vendor",style: TextStyle(fontWeight: FontWeight.bold),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(height: 100,width: 100,child: imgPath["Vendor"]==null?Icon(Icons.file_copy,size: 60,):Image.file(File(imgPath["Vendor"]!)),),
                                TextButton(onPressed: ()async{
                                  XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if(file!=null){
                                    int size = await file!.length()~/1024;
                                    if(size>2048){
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image too big. Please select an image below 2mb")));
                                    }
                                    else{
                                      setState(() {
                                        imgPath["Vendor"]=file?.path;
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
    );
  }

  Future<void> submit(RegisterProvider state)async{
      Map<String,dynamic> data = {};
      setState(() {
        isLoading=true;
      });
      data["img1"]=imgPath["Pan Card"]==null?null:await MultipartFile.fromFile(imgPath["Pan Card"]!);
    data["img2"]=imgPath["KYC"]==null?null:await MultipartFile.fromFile(imgPath["KYC"]!);
    data["img3"]=imgPath["Vendor"]==null?null:await MultipartFile.fromFile(imgPath["Vendor"]!);
    data["img4"]=imgPath["GST"]==null?null:await MultipartFile.fromFile(imgPath["GST"]!);
    CustomLogger.debug(data);
    await completeRegistration3(state,data);
      state.setRegisterProgress(RegisterProgress.completed);
      if(Navigator.canPop(context)){
        Navigator.pop(context);
      }else{
        Navigator.pushReplacementNamed(context, MainPage.routeName);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Congratulations!You have successfully complted your registration process, Please wait for 24-48 working hours for the verification process.")));
        setState(() {
        isLoading=false;
      });

  }

  Widget SignUpButton(BuildContext context,RegisterProvider state){
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: ()async{
              state.setRegisterProgress(RegisterProgress.four);
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Previous",style:TextStyle(color:Colors.red)),
          ),OutlinedButton(
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
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Save&Finish"),
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
  String categoryOption = "Select Category",categoryId="";
  String serviceOption = "Select Service",serviceId="";

  final _formKey = GlobalKey<FormState>();
  bool showLocationList = false;
  bool isLoading = false;
  TextEditingController _serviceDescription = TextEditingController();
  TextEditingController _officePinCode = TextEditingController();
  TextEditingController _officeNo = TextEditingController();
  TextEditingController _officeArea = TextEditingController();
  TextEditingController _officeLandmark = TextEditingController();
  TextEditingController _officeCity = TextEditingController();
  TextEditingController _officeState = TextEditingController();
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
  late DropDownField selectedKyc;
  late RegisterCache cache;
  late Future _getCacheData;
  List<String> dataKeys = ["category_id","service_id","service_desc","office_pincode","office_house_no","office_area","office_landmark","office_city","office_state","price","driver_name","driver_mobile_no","driver_kyc_type","dricer_kyc_no","driver_licence_no","driver_pincode","driver_house_no","driver_area","driver_landmark","driver_city","driver_state"];
  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar Card",value: "AD"),
    DropDownField(title: "Voter Id",value: "VO"),
    DropDownField(title: "Passport",value: "PA"),
    DropDownField(title: "Driving License",value: "DL"),
    DropDownField(title: "Other Govt. Id",value: "OT"),
  ];

  Future<void> getDataFromCache()async{
    await cache.getData(dataKeys);
    selectedKyc = kyctypes.firstWhere((element) => element.value == cache.data["driver_kyc_type"],orElse: ()=>kyctypes[0]);
    _driverKycType.text = selectedKyc.value;
    serviceId=cache.data["service_id"]??"";
    categoryId=cache.data["category_id"]??"";
    _serviceDescription.text =  cache.data["service_desc"]??"";
    _officePinCode.text =  cache.data["office_pincode"]??"";
    _officeNo.text =  cache.data["office_house_no"]??"";
    _officeArea.text =  cache.data["office_area"]??"";
    _officeLandmark.text =  cache.data["office_landmark"]??"";
    _officeCity.text =  cache.data["office_city"]??"";
    _officeState.text =  cache.data["office_state"]??"";
    _price.text =  cache.data["price"]??"";
    _driverName.text =  cache.data["driver_name"]??"";
    _driverMob.text =  cache.data["driver_mobile_no"]??"";
    _driverKycNo.text =  cache.data["dricer_kyc_no"]??"";
    _driverLicense.text =  cache.data["driver_licence_no"]??"";
    _driverpinCode.text =  cache.data["driver_pincode"]??"";
    _driverhouseNo.text =  cache.data["driver_house_no"]??"";
    _driverArea.text =  cache.data["driver_area"]??"";
    _driverLandmark.text =  cache.data["driver_landmark"]??"";
    _driverCity.text =  cache.data["driver_city"]??"";
    _driverState.text =  cache.data["driver_state"]??"";

  }
  @override
  void initState() {
    super.initState();
     cache = RegisterCache(fields: dataKeys);
    _getCacheData = getDataFromCache();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>DropDownOptionProvider(auth: Provider.of<RegisterProvider>(context)),),
        ChangeNotifierProvider(create: (_)=>MapProvider())
      ],
      child: Consumer2<DropDownOptionProvider,RegisterProvider>(
          builder:(context,state,regState,child){
            if(regState.isLoading || state.isLoading){
              return LoadingWidget();
            }

            return FutureBuilder(
              future: _getCacheData,
              builder: (context, snapshot) {
                return Consumer<MapProvider>(
                  builder:(context,mapState,child)=>Scaffold(
                    appBar: AppBar(automaticallyImplyLeading: false,),
                    body: Form(
                      key: _formKey,
                      child: Container(
                        padding: EdgeInsets.all(11),
                        height: double.infinity,
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                              children:<Widget>[
                                SizedBox(
                                  height: 10.h,
                                  width: 20.w,
                                  child: Image.asset("assets/images/logo/logo-nav.png"),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin:const EdgeInsets.symmetric(vertical: 10),
                                  child:const Text("Provide your details below"),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                  child: Text("Office details",style: TextStyle(fontWeight: FontWeight.w500),),
                                ),
                                InputField("Office Number", _officeNo),
                                InputField("Area", _officeArea),
                                InputField("Landmark", _officeLandmark),
                                InputField("City", _officeCity),
                                InputField("PinCode", _officePinCode),
                                InputField("State", _officeState),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                  child: Text("Service details",style: TextStyle(fontWeight: FontWeight.w500),),
                                ),
                                ExpansionTile(
                                  key: GlobalKey(),
                                  title: Text(serviceOption),
                                  children: state.options!.serviceOptions.map(
                                        (e) => ListTile(title: Text(e.service),onTap: (){
                                      setState(() {
                                        serviceOption = e.service ;
                                        serviceId = e.id ;
                                      });
                                    },),).toList(),
                                ),
                                ExpansionTile(
                                  key: GlobalKey(),
                                  title: Text(categoryOption),
                                  children: state.options!.categoryOptions.map(
                                        (e) => ListTile(title: Text(e.name),onTap: (){
                                      setState(() {
                                        categoryOption = e.name ;
                                        categoryId = e.id;
                                      });
                                    },),).toList(),
                                ),
                                InputField("Service Description", _serviceDescription),
                                InputField("Price", _price),
                                if(serviceOption.toLowerCase().contains("car"))
                                  Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                        child: Text("Driver details",style: TextStyle(fontWeight: FontWeight.w500),),
                                      ),
                                      InputField("Name", _driverName),
                                      InputField("Mobile Number", _driverMob,),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 45),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Kyc Type"),
                                            DropdownButton(
                                              value: selectedKyc,
                                              items: kyctypes.map((e)=>DropdownMenuItem(child: Text(e.title),value: e,)).toList(),
                                              onChanged: (_){
                                                setState(() {
                                                  _driverKycType.text = _!.value ;
                                                  selectedKyc = _ ;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      InputField("KYC Number", _driverKycNo),
                                      InputField("License", _driverLicense),
                                      InputField("PinCode", _driverpinCode),
                                      InputField("House Number", _driverhouseNo),
                                      InputField("Area", _driverArea),
                                      InputField("Landmark", _driverLandmark),
                                      InputField("City", _driverCity),
                                      InputField("State", _driverState),
                                    ],
                                  ),
                                if(isLoading)
                                  Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                                else
                                  CreateButton(context, Provider.of<RegisterProvider>(context)),
                              ]
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            );
          }
      ),
    );
  }
  Widget CreateButton(BuildContext context,RegisterProvider state){
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: (){
              state.setRegisterProgress(RegisterProgress.two);
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Previous",style:TextStyle(color:Colors.red)),
          ),OutlinedButton(
            onPressed: (){
              setState(() {
                isLoading = true;
              });
              createService(state);
              setState(() {
                isLoading = false;
              });
            },
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
            ),
            child: const Text("Save&Next"),
          ),
        ],
      ),
    );
  }
  Widget InputField(String title,TextEditingController controller,{MapProvider? state,bool hide=false,bool autoComplete = false}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
      child: TextFormField(
        obscureText: hide,
        controller: controller,
        onChanged: autoComplete?(text){
          state!.getLocations(text);
          setState(() {
            showLocationList=true;
          });
        }:null,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.home_repair_service),
            labelText: title,border: const OutlineInputBorder()),
        validator: (text){
          if(text?.length==0){
            return "Required field";
          }
        },
      ),
    );
  }
  void createService(RegisterProvider state){
    if(_formKey.currentState!.validate()){
      Map data = {
        "category_id":categoryId,//
        "service_id":serviceId,//
        "service_desc":_serviceDescription.text,//
        "office_pincode":_officePinCode.text,
        "office_house_no":_officeNo.text,
        "office_area":_officeArea.text,
        "office_landmark":_officeLandmark.text,
        "office_city":_officeCity.text,
        "office_state":_officeState,
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
      };
      CustomLogger.debug(data);
      try{
        completeRegistrationIntermediate(state, data);
        cache.setData(data);
        state.setRegisterProgress(RegisterProgress.four);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service created successfully")));
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

}
