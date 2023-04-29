import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/ServiceProvider.dart';
import 'package:utsavlife/core/provider/mapProvider.dart';
import 'package:utsavlife/core/repo/service.dart' as serviceRepo ;
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/routes/errorScreen.dart';

import '../core/models/dropdown.dart';
import 'CompleteRegistration.dart';

class AddServiceRoute extends StatefulWidget {
  static const routeName = "/addservice";
  const AddServiceRoute({Key? key}) : super(key: key);

  @override
  State<AddServiceRoute> createState() => _AddServiceRouteState();
}

class _AddServiceRouteState extends State<AddServiceRoute> {
  String categoryOption = "Select Category",categoryId="";
  String serviceOption = "Select Service",serviceId="";

  final _formKey = GlobalKey<FormState>();
  bool showLocationList = false;
  bool isLoading = false;
  TextEditingController _companyName = TextEditingController();
  TextEditingController _companyAddress = TextEditingController();
  TextEditingController _serviceDescription = TextEditingController();
  TextEditingController _materialDescription = TextEditingController();
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

  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar Card",value: "AD"),
    DropDownField(title: "Voter Id",value: "VO"),
    DropDownField(title: "Passport",value: "PA"),
    DropDownField(title: "Driving License",value: "DL"),
    DropDownField(title: "Other Govt. Id",value: "OT"),
  ];
  @override
  void initState() {
    super.initState();
    _driverKycType.text = kyctypes[0].value;
    selectedKyc = kyctypes[0];
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
           ChangeNotifierProvider(create: (_)=>DropDownOptionProvider(auth: Provider.of<AuthProvider>(context)),),
            ChangeNotifierProvider(create: (_)=>MapProvider())
      ],
      child: Consumer<DropDownOptionProvider>(
        builder:(context,state,child){
          if(state.auth.user?.kycType==null){
            return errorScreenRoute(icon: Icons.error_outline, message: "Please complete your registration first.");
          }
         if(state.isLoading){
           return Container(
             color: Colors.white,
             alignment: Alignment.center,
             child: CircularProgressIndicator(),
           );
         }
          return Consumer<MapProvider>(
            builder:(context,mapState,child)=>Scaffold(
              appBar: AppBar(),
              body: Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(11),
                  height: double.infinity,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      children:<Widget>[
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
                        InputField("Company Name", _companyName),
                        InputField("Address", _companyAddress,autoComplete: true,state: mapState),
                        if(showLocationList&&mapState.locations.isNotEmpty)
                          ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,itemCount: min(6, mapState.locations.length),itemBuilder: (context,index)=>ListTile(leading: Icon(Icons.location_on),title: Text(mapState.locations[index]),onTap: (){
                            _companyAddress.text = mapState.locations[index];
                            setState(() {
                              showLocationList=false;
                            });
                          },)),
                        InputField("Service Description", _serviceDescription),
                        InputField("Material Description", _materialDescription),
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
                            InputField("Mobile Number", _driverMob),
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
                          CreateButton(context, state.auth),
                      ]
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
  Widget CreateButton(BuildContext context,AuthProvider auth){
    return Container(
      margin: EdgeInsets.all(20),
      child: OutlinedButton(
        onPressed: (){
          setState(() {
            isLoading = true;
          });
          createService(auth);
          setState(() {
            isLoading = false;
          });
        },
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
        ),
        child: const Text("Create Service"),
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
  void createService(AuthProvider auth){
    if(_formKey.currentState!.validate()){
      Map serviceData = {
        "category_id":categoryId,
        "service_id":serviceId,
        "company_name":_companyName.text,
        "address":_companyAddress.text,
        "service_desc":_serviceDescription.text,
        "material_desc":_materialDescription.text,
        "price":_price.text,
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
      CustomLogger.debug(serviceData);
      try{
        serviceRepo.createService(auth, serviceData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service created successfully")));
        Navigator.pop(context);
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

}
