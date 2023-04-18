import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/mapProvider.dart';
import 'package:utsavlife/core/repo/auth.dart';
import 'package:utsavlife/core/utils/logger.dart';

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
  final TextEditingController _mobileNo=TextEditingController();
  final TextEditingController _password=TextEditingController();
  final TextEditingController _address=TextEditingController();
  final TextEditingController _area=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _controllers;
  bool showLocationList = false ;
  bool isLoading = false;
  @override
  void initState() {
    _controllers = [
      _email,
      _name,
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
      child: ListenableProvider(
        create: (_)=>MapProvider(),
        child: Consumer<MapProvider>(
          builder:(context,state,child)=>GestureDetector(
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
                        InputField("Email", _email),
                        InputField("Password", _password,hide: true),
                        InputField("Mobile number", _mobileNo),
                        InputField("Address", _address,autocomplete:true,state: state),
                        if(showLocationList&&state.locations.isNotEmpty)
                        ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,itemCount: min(6, state.locations.length),itemBuilder: (context,index)=>ListTile(leading: Icon(Icons.location_on),title: Text(state.locations[index]),onTap: (){
                          _address.text = state.locations[index];
                          setState(() {
                            showLocationList=false;
                          });
                        },)),
                        InputField("Area covered (Km radius)", _area),
                        if(isLoading)Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
                        else SignUpButton(context,state),
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
  Future<void> submit(MapProvider state)async{
    if(_formKey.currentState!.validate()){
      await state.getLatLong(_address.text);
      CustomLogger.debug(state.coordinates);
      Map data = {
        "name":_name.text.toString(),
        "email":_email.text,
        "password":_password.text,
        "mobile":_mobileNo.text,
        "address_address":_address.text,
        "distance_cover":_area.text,
        "address_latitude":state.coordinates.latitude,
        "address_longitude":state.coordinates.longitude
      } ;
      CustomLogger.debug(data);
      await signUpMain(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup successful. Login to continue")));
      Navigator.pop(context);
    }
    else{
      setState(() {
        isLoading=false;
      });
    }
  }
  Widget SignUpButton(BuildContext context,MapProvider state){
    return Container(
      margin: EdgeInsets.all(20),
      child: OutlinedButton(
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
        child: const Text("Create Account"),
      ),
    );
  }
  Widget InputField(String title,TextEditingController controller,{bool hide=false,bool autocomplete=true,MapProvider? state}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
      child: TextFormField(
        obscureText: hide,
        controller: controller,
        validator: (text){
          if(text?.length==0) return "Required field";
        },
        onChanged: (text){
          if(state!=null){
            setState(() {
              showLocationList=true;
            });
            state.getLocations(text);
          }
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            labelText: title,border: const OutlineInputBorder()),
      ),
    );
  }
}
