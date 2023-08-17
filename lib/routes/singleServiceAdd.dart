import 'dart:math';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/loading.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/ServiceProvider.dart';
import 'package:utsavlife/core/provider/mapProvider.dart';
import 'package:utsavlife/core/repo/service.dart' as serviceRepo ;
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/routes/errorScreen.dart';
import '../core/models/dropdown.dart';

class AddServiceRoute extends StatefulWidget {
  static const routeName = "/addservice";
  const AddServiceRoute({Key? key}) : super(key: key);

  @override
  State<AddServiceRoute> createState() => _AddServiceRouteState();
}

class _AddServiceRouteState extends State<AddServiceRoute> {
  String serviceOption = "Select Service",serviceId="";

  final _formKey = GlobalKey<FormState>();
  bool showLocationList = false;
  bool isLoading = false;
  String? videoPath;
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
  String? driverImage,drivingLicenseImage;
  List<AddProductPhoto> productImages = [];
  late DropDownField selectedKyc;

  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar",value: "AD"),
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
         if(state.isLoading && state.options==null) {
           return LoadingWidget(willRedirect:true,);
         }
         if(state.options==null)
           {
             state.getOptions();
             return LoadingWidget(willRedirect:true,);
           }
          return Consumer<MapProvider>(
            builder:(context,mapState,child)=>Scaffold(
              appBar: AppBar(
                title: Text("Add service"),
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
                        InputField("Price", _price,digits:true),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Product photos. Max 5",style: TextStyle(fontWeight: FontWeight.bold),),
                              OutlinedButton(onPressed: ()async{
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
                          child: Text("Add a video",style: TextStyle(fontWeight: FontWeight.bold),),
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
                              Container(child: TextButton(child:const Text("Choose"),onPressed: ()async{
                                XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
                                setState(() {
                                  videoPath = video?.path;
                                });
                              },),)
                            ],
                          ),
                        ),
                        if(serviceOption.toLowerCase().contains("car"))
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                              child: Text("Driver details",style: TextStyle(fontWeight: FontWeight.w500),),
                            ),
                            InputField("Name", _driverName),
                            InputField("Mobile Number", _driverMob,validatePhone:true),
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
                            InputField("${selectedKyc.title} Number", _driverKycNo),
                            InputField("License", _driverLicense),
                            InputField("PinCode", _driverpinCode),
                            InputField("House Number", _driverhouseNo),
                            InputField("Area", _driverArea),
                            InputField("Landmark", _driverLandmark),
                            InputField("City", _driverCity),
                            InputField("State", _driverState),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                              child: Text("Choose Driver Image",style: TextStyle(fontWeight: FontWeight.bold),),
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
                                  Container(child: TextButton(child:const Text("Choose"),onPressed: ()async{
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
                              child: Text("Choose Driving License Image",style: TextStyle(fontWeight: FontWeight.bold),),
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
                                  Container(child: TextButton(child:const Text("Choose"),onPressed: ()async{
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
        },
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
        ),
        child: const Text("Create Service"),
      ),
    );
  }
  Widget InputField(String title,TextEditingController controller,{MapProvider? state,bool hide=false,bool autoComplete = false,validatePhone=false,digits=false}){

    return Container(
      margin:const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
      child: TextFormField(
        keyboardType: validatePhone||digits?TextInputType.phone:TextInputType.text,
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
          if(validatePhone){
            if(text==null || text.length<10)return "Please enter a valid number";
          }
      },
      ),
    );
  }
  void createService(AuthProvider auth)async{
    if(_formKey.currentState!.validate()){
      Map<String,dynamic> serviceData = {
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
       "img6":driverImage==null?null:await MultipartFile.fromFile(driverImage!),
       "img5":drivingLicenseImage==null?null:await MultipartFile.fromFile(drivingLicenseImage!),
        "video":videoPath==null?null:await MultipartFile.fromFile(videoPath!)
      };
      for(int i = 0;i<productImages.length;i++){
        serviceData['pmg${i+1}']=productImages[i].filePath==null?null:await MultipartFile.fromFile(productImages[i].filePath!);
      }
      CustomLogger.debug(serviceData);
      try{
        await serviceRepo.createService(auth, serviceData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service created successfully")));
        Navigator.pop(context);
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

}

class AddProductPhoto extends StatefulWidget {
  int id;
  Function(int) onDelete;
  String? filePath;
  bool network;
  AddProductPhoto({Key? key,required this.id,required this.onDelete,this.filePath,this.network = false}) : super(key: key);

  @override
  State<AddProductPhoto> createState() => _AddProductPhotoState();
}

class _AddProductPhotoState extends State<AddProductPhoto> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
      height: 10.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 80,height: 60,child: widget.filePath==null?Text("Select Image"):widget.network?CachedNetworkImage(imageUrl:widget.filePath!):Image.file(File(widget.filePath!)),),
          Container(child: TextButton(onPressed: ()async{
            XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
            int? length = await file?.length();
            if((length!/1024) > 2048){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image size should be less than 2mb")));
              return;
            }
            setState(() {
              widget.network = false;
              widget.filePath = file?.path;
            });
          },child: Text("Change Image"),),),
          Container(child: IconButton(onPressed: (){
            widget.onDelete(widget.id);
          },icon: Icon(Icons.delete),),)
        ],
      ),
    );
  }
}

