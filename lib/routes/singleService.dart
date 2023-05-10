import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/models/service.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/service.dart' as serviceRepo;
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/routes/VideoPlayer.dart';
import 'package:utsavlife/routes/imageViewPage.dart';
import 'package:utsavlife/routes/singleServiceAdd.dart';
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
  final String imageUrl = "storage/app/public/vandor/product_image";
  final String driverUrl = "storage/app/public/vandor/driver_image";
  final String dlUrl = "storage/app/public/vandor/dl_image";
  final String videoUrl = "storage/app/public/vandor/video";
  late CustomFieldController _service,
      _description,_material,_address,_price,_category,
      _driverName,_driverMob,_driverKycType,
      _driverKycNo,_licenseNo,_pinCode,_houseNo,
      _area,_landmark,_city,_state;
  final TextEditingController _categoryDescription = TextEditingController();
  final TextEditingController _priceBasis = TextEditingController();
  final TextEditingController _discountedPrice = TextEditingController();
  List<CustomFieldController> controllers =[];
  List<AddProductPhoto> productImages = [];
  String? videoPath;
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
          builder:(context,DropDownstate,child){
            return Scaffold(
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
                                    productImages = [];
                                    for(var i in widget.service.imageUrls){
                                      if(i!=null)
                                      productImages.add(AddProductPhoto(
                                          network: true,
                                          filePath: "${APIConfig.baseUrl}/${imageUrl}/${i}",
                                          id: productImages.length, onDelete: (id){
                                        setState(() {
                                          productImages.removeWhere((element) => element.id == id);
                                        });
                                      }));
                                    }
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
                          alignment: Alignment.centerLeft,
                          height: 10.h,
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
                        DetailTile("Category Description", widget.service.categoryDescription,controller: _categoryDescription,big: true,editable: false),
                        SizedBox(height: 20,),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                          child: Text("General Information",style: Theme.of(context).textTheme.bodyMedium,),
                        ),
                        DetailTile("Description", widget.service.serviceDescription,controller: _description.controller),
                        DetailTile("Address", widget.service.address,controller: _address.controller),
                        DetailTile("Material Description", widget.service.materialDescription,controller: _material.controller),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                          child: Text("Product Images",style: TextStyle(fontWeight: FontWeight.bold),),),
                        if(widget.service.imageUrls.isNotEmpty && canEdit)
                         Column(
                           children: [
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
                           ],
                         ),
                        if(widget.service.imageUrls.isNotEmpty && !canEdit)
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                          height: 20.h,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: widget.service.imageUrls.where((element) => element!=null).map((e) => GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageViewer(imageUrl: "${APIConfig.baseUrl}/${imageUrl}/${e}")));
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                width: 60.w,height: 80,child:CachedNetworkImage(imageUrl: "${APIConfig.baseUrl}/${imageUrl}/${e}",),),
                            )).toList(),
                          ),
                        ),
                        if(widget.service.videoUrl!=null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                              child: Text("Product Video",style: TextStyle(fontWeight: FontWeight.bold),),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  child: Text("View"),
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoApp(url: "${APIConfig.baseUrl}/${videoUrl}/${widget.service.videoUrl}")));
                                  },
                                ),
                                if(canEdit)
                                  OutlinedButton(
                                    child: Text("Change/Upload"),
                                    onPressed: ()async{
                                      XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
                                      setState(() {
                                        videoPath = video?.path!;
                                      });},
                                  ),
                              ],
                            )
                          ],
                        ),
                        Row(
                        children: [
                          Expanded(child:DetailTile("Price", widget.service.price,controller: _price.controller),),
                          Expanded(child:DetailTile("Price basis", widget.service.priceBasis,controller: _priceBasis,editable: false)),
                        ],
                        ),
                        DetailTile("Discounted Price", widget.service.discountedPrice,controller: _discountedPrice,editable: false),
                        SizedBox(height: 20,),

                        SizedBox(height: 20,),
                        if(widget.service.serviceName!.contains("car"))
                          Column(
                            children: [
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
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                child: Text("Driver Image",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageViewer(imageUrl: "${APIConfig.baseUrl}/${driverUrl}/${widget.service.driverDetails.image}")));
                                },
                                child: Container(
                                  width: 60.w,
                                  height: 120,
                                  margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                  child: CachedNetworkImage(imageUrl: "${APIConfig.baseUrl}/${driverUrl}/${widget.service.driverDetails.image}",),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                child: Text("Driving license Image",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageViewer(imageUrl: "${APIConfig.baseUrl}/${dlUrl}/${widget.service.driverDetails.dlImage}")));
                                },
                                child: Container(
                                  width: 60.w,
                                  height: 120,
                                  margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                  child: CachedNetworkImage(imageUrl: "${APIConfig.baseUrl}/${dlUrl}/${widget.service.driverDetails.dlImage}",),
                                ),
                              ),
                            ],
                          ),
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
          );}
        ),
      ),
    );
  }
  void update(AuthProvider auth)async{
      Map data = {"id":widget.service.id,"service_id":widget.service.serviceId};
      if(videoPath!=null){
        data["video"]=await MultipartFile.fromFile(videoPath!);
      }
      for (var i in controllers){
          if(i.controller.text.isNotEmpty){
            data[i.key]=i.controller.text ;
          }
      }
      for(int j = 0; j<productImages.length;j++){
        if(productImages[j].network==false){
          data["pmg${j+1}"]=await MultipartFile.fromFile(productImages[j].filePath!);
        }
      }
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
