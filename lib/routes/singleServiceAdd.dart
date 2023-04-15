import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/ServiceProvider.dart';
import 'package:utsavlife/core/repo/service.dart' as serviceRepo ;
import 'package:utsavlife/core/utils/logger.dart';

class AddServiceRoute extends StatefulWidget {
  static const routeName = "/addservice";
  const AddServiceRoute({Key? key}) : super(key: key);

  @override
  State<AddServiceRoute> createState() => _AddServiceRouteState();
}

class _AddServiceRouteState extends State<AddServiceRoute> {
  String categoryOption = "Select Category",categoryId="";
  String serviceOption = "Select Service",serviceId="";
  List<Map> controllers = [
  {"title":"Company Name","key":"company_name","controller":TextEditingController()},
  {"title":"Address","key":"address","controller":TextEditingController()},
  {"title":"Service Description","key":"service_desc","controller":TextEditingController()},
  {"title":"Material Description","key":"material_desc","controller":TextEditingController()},
  {"title":"Price","key":"price","controller":TextEditingController()},
  {"title":"Driver Name","key":"driver_name","controller":TextEditingController()},
  {"title":"Driver Mobile Number","key":"driver_mobile_no","controller":TextEditingController()},
  {"title":"Driver KYC Type","key":"driver_kyc_type","controller":TextEditingController()},
  {"title":"Driver KYC Number","key":"dricer_kyc_no","controller":TextEditingController()},
  {"title":"Driver License Number","key":"driver_licence_no","controller":TextEditingController()},
  {"title":"Driver Pincode","key":"driver_pincode","controller":TextEditingController()},
  {"title":"Driver house Number","key":"driver_house_no","controller":TextEditingController()},
  {"title":"Driver Area","key":"driver_area","controller":TextEditingController()},
  {"title":"Driver Landmark","key":"driver_landmark","controller":TextEditingController()},
  {"title":"Driver City","key":"driver_city","controller":TextEditingController()},
  {"title":"Driver State","key":"driver_state","controller":TextEditingController()},
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (_)=>DropDownOptionProvider(auth: Provider.of<AuthProvider>(context)),
      child: Consumer<DropDownOptionProvider>(
        builder:(context,state,child){
         if(state.isLoading){
           return Container(
             color: Colors.white,
             alignment: Alignment.center,
             child: CircularProgressIndicator(),
           );
         }
          return Scaffold(
            appBar: AppBar(),
            body: Container(
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
                    )
                  ]+controllers.map((e) => InputField(e["title"], e["controller"])).toList()+[CreateButton(context,Provider.of<AuthProvider>(context))],
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
          createService(auth);
        },
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
        ),
        child: const Text("Create Service"),
      ),
    );
  }
  Widget InputField(String title,TextEditingController controller,{bool hide=false}){
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
      child: TextFormField(
        obscureText: hide,
        controller: controller,
        decoration: InputDecoration(labelText: title,border: const OutlineInputBorder()),
      ),
    );
  }
  void createService(AuthProvider auth){
    Map serviceData = {
      "category_id":categoryId,
      "service_id":serviceId,
    };
    for(var i in controllers){
      if(!i["controller"].text.isEmpty){
        serviceData[i["key"]]=i["controller"].text;
      }
    }
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
