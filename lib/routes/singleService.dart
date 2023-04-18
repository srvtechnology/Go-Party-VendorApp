import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/service.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/service.dart' as serviceRepo;
import 'package:utsavlife/core/utils/logger.dart';

import '../core/provider/ServiceProvider.dart';
class SingleService extends StatefulWidget {
  final serviceModel service;
  SingleService({Key? key,required this.service}) : super(key: key);

  @override
  State<SingleService> createState() => _SingleServiceState();
}

class CustomFieldController{
  String title,key;
  late TextEditingController controller;
  CustomFieldController({required this.title,required this.key}){
    controller = TextEditingController();
  }
}

class _SingleServiceState extends State<SingleService> {
  bool canEdit = false ;
  late CustomFieldController _service,
      _description,_material,_address,_price,_category,
      _driverName,_driverMob,_driverKycType,
      _driverKycNo,_licenseNo,_pinCode,_houseNo,
      _area,_landmark,_city,_state;
  List<CustomFieldController> controllers =[];
    @override
  void initState() {
    super.initState();
      _service = CustomFieldController(title: "Service", key: "service_id");
      _description = CustomFieldController(title: "Description", key: "service_desc");
      _material = CustomFieldController(title: "Material Description", key: "material_desc");
      _address = CustomFieldController(title: "Address", key: "address");
      _price = CustomFieldController(title: "Price", key: "price");
      _category = CustomFieldController(title: "Category", key: "category_id");
      _driverName = CustomFieldController(title: "Driver Name", key: "driver_name");
      _driverMob = CustomFieldController(title: "Driver Mobile Number", key: "driver_mobile_no");
      _driverKycType = CustomFieldController(title: "Driver Kyc Type", key: "driver_kyc_type");
      _driverKycNo = CustomFieldController(title: "Driver KYC Number", key: "dricer_kyc_no");
      _licenseNo = CustomFieldController(title: "Driver License Number", key: "driver_licence_no");
      _pinCode = CustomFieldController(title: "Driver Pin Code", key: "driver_pincode");
      _houseNo = CustomFieldController(title: "Driver House Number", key: "driver_house_no");
      _area = CustomFieldController(title: "Driver Area", key: "driver_area");
      _landmark = CustomFieldController(title: "Driver Landmark", key: "driver_landmark");
      _city = CustomFieldController(title: "Driver City", key: "driver_city");
      _state = CustomFieldController(title: "Driver State", key: "driver_state");
      controllers = [_service,
        _description,_address,_material,_price,_category,
        _driverName,_driverMob,_driverKycType,
        _driverKycNo,_licenseNo,_pinCode,_houseNo,
        _area,_landmark,_city,_state];
    }
  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (_)=>DropDownOptionProvider(auth: Provider.of<AuthProvider>(context)),
      child: Consumer<AuthProvider>(
        builder:(context,state,child)=> Consumer<DropDownOptionProvider>(
          builder:(context,DropDownstate,child)=>Scaffold(
            appBar: AppBar(title: Text("Service details"),),
            body: Container(
              height: double.infinity,
              width: double.infinity,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(-3,3),
                        color: Colors.grey[200]!,
                        blurRadius: 1
                    ),
                    BoxShadow(
                        offset: Offset(3,-3),
                        color: Colors.grey[200]!,
                        blurRadius: 1
                    ),
                    BoxShadow(
                        offset: Offset(-3,0),
                        color: Colors.grey[200]!,
                        blurRadius: 1
                    ),
                    BoxShadow(
                        offset: Offset(0,-3),
                        color: Colors.grey[200]!,
                        blurRadius: 1
                    ),
                  ]
              ),
              child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: (){
                                  setState(() {
                                    canEdit = !canEdit;
                                  });
                                  //deleteService(state);
                                },
                                icon: Icon(Icons.edit,color: canEdit?Colors.blue:Colors.grey,),
                              ),
                            ),Container(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: (){
                                  deleteService(state);
                                },
                                icon: Icon(Icons.delete,color: Colors.red,),
                              ),
                            ),
                          ],
                        ),
                        if(canEdit)
                          ExpansionTile(
                            key: GlobalKey(),
                            title: Text(widget.service.serviceName??"Service"),
                            children: DropDownstate.options!.serviceOptions.map(
                                  (e) => ListTile(title: Text(e.service),onTap: (){
                                setState(() {
                                  _service.controller.text = e.id ;
                                  widget.service.serviceName = e.service ;
                                });
                              },),).toList(),
                          )
                        else
                        Container(
                          height: 5.h,
                          margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          child: Text("${widget.service.serviceName}",style: Theme.of(context).textTheme.headlineSmall,),
                        ),
                        if(canEdit)
                          ExpansionTile(
                            key: GlobalKey(),
                            title: Text(widget.service.categoryName??"Category"),
                            children: DropDownstate.options!.categoryOptions.map(
                                  (e) => ListTile(title: Text(e.name),onTap: (){
                                setState(() {
                                  _category.controller.text = e.id ;
                                  widget.service.categoryName = e.name ;
                                  widget.service.categoryDescription = e.description;
                                });
                              },),).toList(),
                          )
                        else
                          DetailTile("Category", widget.service.categoryName,controller: _category.controller),
                        DetailTile("Category Description", widget.service.categoryDescription,big: true,editable: false),
                        SizedBox(height: 20,),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                          child: Text("General Information",style: Theme.of(context).textTheme.bodyMedium,),
                        ),
                        DetailTile("Description", widget.service.serviceDescription,controller: _description.controller),
                        DetailTile("Address", widget.service.address,controller: _address.controller),
                        DetailTile("Material Description", widget.service.materialDescription,controller: _material.controller),

                        Row(
                        children: [
                        Expanded(child:DetailTile("Price", widget.service.price,controller: _price.controller),),
                        Expanded(child:DetailTile("Price basis", widget.service.priceBasis)),
                        ],
                        ),
                        DetailTile("Discounted Price", widget.service.discountedPrice),
                        SizedBox(height: 20,),
                        Container(
                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                        child: Text("Category Details",style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        SizedBox(height: 20,),
                        Container(
                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                        child: Text("Driver Details",style: Theme.of(context).textTheme.bodyMedium,),
                        ),
                        Row(
                        children: [
                            Expanded(child:DetailTile("Name", widget.service.driverDetails.name,controller: _driverName.controller)),
                            Expanded(child:DetailTile("Mobile number", widget.service.driverDetails.mobileNumber,controller: _driverMob.controller)),
                        ],
                        ),
                        Row(
                        children: [
                        Expanded(child:DetailTile("KYC Type", widget.service.driverDetails.kycType,controller: _driverKycType.controller)),
                        Expanded(child:DetailTile("KYC number", widget.service.driverDetails.kycNumber,controller: _driverKycNo.controller)),
                        ],
                        ),
                        Row(
                        children: [
                        Expanded(child:DetailTile("License Number", widget.service.driverDetails.licenseNumber,controller: _licenseNo.controller)),
                        Expanded(child:DetailTile("Pin Code", widget.service.driverDetails.pinCode,controller: _pinCode.controller)),
                        ],
                        ),
                        Row(
                        children: [
                        Expanded(child:DetailTile("House Number", widget.service.driverDetails.houseNumber,controller: _houseNo.controller)),
                        Expanded(child:DetailTile("Area", widget.service.driverDetails.area,controller: _area.controller)),
                        ],
                        ),Row(
                        children: [
                        Expanded(child:DetailTile("City", widget.service.driverDetails.city,controller: _city.controller)),
                        Expanded(child:DetailTile("State", widget.service.driverDetails.state,controller: _state.controller)),
                        ],
                        ),
                        DetailTile("Landmark", widget.service.driverDetails.landmark,controller: _landmark.controller),
                        if(canEdit)
                          Container(
                            alignment: Alignment.center,
                            child: OutlinedButton(onPressed: (){
                              update(state);
                            }, child: Text("Save")),
                          )
                      ],
                    ),
                  ))
          ),
        ),
      ),
    );
  }
  void update(AuthProvider auth)async{
      Map data = {"id":widget.service.id};

      for (var i in controllers){
          if(i.controller.text.isNotEmpty){
            data[i.key]=i.controller.text ;
          }
      }
      CustomLogger.error(data);
      try{
        serviceRepo.updateService(auth, widget.service.id,data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully Edited")));
      }
      catch(e)
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
      setState(() {
        canEdit = false;
      });
  }
  Widget DetailTile(String header,String? body,{TextEditingController? controller,bool editable=true,bool big=false}){
  if(body=="" || body==null)body="Not set";
  controller?.text = body ;
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: big?4:1,
        decoration: InputDecoration(
            labelText: header
        ),
        readOnly: !(editable&&canEdit),
      )
  );
}
void deleteService(AuthProvider auth){
    try{
    serviceRepo.deleteService(auth, widget.service.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successful")));
    Navigator.pop(context);
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
}
}
