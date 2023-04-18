import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/errorScreen.dart';

import '../core/repo/auth.dart';
import '../core/utils/logger.dart';

class CompleteRegistrationRoute extends StatefulWidget {
  static const routeName = "registration2";
  const CompleteRegistrationRoute({Key? key}) : super(key: key);

  @override
  State<CompleteRegistrationRoute> createState() => _CompleteRegistrationRouteState();
}
class DropDownField{
  String title;
  String value;
  DropDownField({required this.title,required this.value});
}
class _CompleteRegistrationRouteState extends State<CompleteRegistrationRoute> {
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
  late DropDownField selectedKyc;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _kycType.text = kyctypes[0].value;
    selectedKyc = kyctypes[0];
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder:(context,state,child){
        if(state.user?.kycType!=null){
          return errorScreenRoute(icon: Icons.error, message: "You have already completed the registration");
        }
        return Scaffold(
          appBar: AppBar(),
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
                    InputField("Pan Card", _pancard),
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
                    InputField("KYC Number", _kycNo),
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
            "state":_state.text
      } ;
      setState(() {
        isLoading=false;
      });
      await completeRegistration(state,data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your data has been successfully recorded.")));
      Navigator.pop(context);
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

  Widget InputField(String title,TextEditingController controller,{bool hide=false,bool autocomplete=true}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
      child: TextFormField(
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
