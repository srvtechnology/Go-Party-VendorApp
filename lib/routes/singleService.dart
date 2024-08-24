import 'package:cached_network_image/cached_network_image.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/components/customBox.dart';
import 'package:utsavlife/core/components/gradientButton.dart';
import 'package:utsavlife/core/models/service.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/service.dart' as serviceRepo;
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/routes/VideoPlayer.dart';
import 'package:utsavlife/routes/imageViewPage.dart';
import 'package:utsavlife/routes/singleServiceAdd.dart';
import '../core/provider/ServiceProvider.dart';
import '../core/repo/maps.dart';
import '../core/utils/UIColor.dart';


class SingleService extends StatefulWidget {
  final ServiceModel service;
  SingleService({Key? key,required this.service}) : super(key: key);

  @override
  State<SingleService> createState() => _SingleServiceState();
}

class CustomFieldController{
  String title,key;
  final TextEditingController controller=TextEditingController();
  CustomFieldController({required this.title,required this.key});
}

class _SingleServiceState extends State<SingleService> {
  bool canEdit = false ;
  final String imageUrl = "storage/app/public/vandor/product_image";
  final String driverUrl = "storage/app/public/vandor/driver_image";
  final String dlUrl = "storage/app/public/vandor/dl_image";

  final CustomFieldController _service = CustomFieldController(title: "Service", key: "service_id");
  final CustomFieldController _description = CustomFieldController(title: "Description", key: "service_desc");
  final CustomFieldController _material = CustomFieldController(title: "Material Description", key: "material_desc");
  final CustomFieldController _address = CustomFieldController(title: "Address", key: "address");
  final CustomFieldController _price = CustomFieldController(title: "Price", key: "price");
  final CustomFieldController _driverName = CustomFieldController(title: "Driver Name", key: "driver_name");
  final CustomFieldController _driverMob = CustomFieldController(title: "Driver Mobile Number", key: "driver_mobile_no");
  final CustomFieldController _driverKycType = CustomFieldController(title: "Driver Kyc Type", key: "driver_kyc_type");
  final CustomFieldController _driverKycNo = CustomFieldController(title: "Driver KYC Number", key: "dricer_kyc_no");
  final CustomFieldController _licenseNo = CustomFieldController(title: "Driver License Number", key: "driver_licence_no");
  final CustomFieldController _driverPinCode = CustomFieldController(title: "Driver Pin Code", key: "driver_pincode");
  final CustomFieldController _driverHouseNo = CustomFieldController(title: "Driver House Number", key: "driver_house_no");
  final CustomFieldController _driverArea = CustomFieldController(title: "Driver Area", key: "driver_area");
  final CustomFieldController _driverLandmark = CustomFieldController(title: "Driver Landmark", key: "driver_landmark");
  final CustomFieldController _driverCity = CustomFieldController(title: "Driver City", key: "driver_city");
  final CustomFieldController _driverState = CustomFieldController(title: "Driver State", key: "driver_state");
  final CustomFieldController _pinCode = CustomFieldController(title: "Pin Code", key: "pin_code");
  final CustomFieldController _companyName = CustomFieldController(title: "Company Name", key: "company_name");
  final CustomFieldController _videoUrl = CustomFieldController(title: "Video URL", key: "video");

  final TextEditingController _priceBasis = TextEditingController();
  final TextEditingController _discountedPrice = TextEditingController();
  late List<CustomFieldController> controllers;
  List<AddProductPhoto> productImages = [];

  bool isLoading = false ;
  bool isDeleteLoading = false;

  String? selectedCountry = "India", selectedState, selectedCity;
  Future _locationFuture = Future.value({});

  @override
  void initState() {
    super.initState();
    _service.controller.text = widget.service.serviceId??"1";

    selectedCountry = widget.service.country_id ?? "India";
    selectedState = widget.service.state_id ?? "";
    selectedCity = widget.service.city_id ?? "";

    controllers = [_service,_description,_material,_address,_price,
      _driverName,_driverMob,_driverKycType,
      _driverKycNo,_licenseNo,_driverPinCode,_driverHouseNo,_driverArea,
      _driverLandmark,_driverCity,_driverState,_pinCode,_videoUrl,_companyName
    ];

    _pinCode.controller.addListener((){
      if(_pinCode.controller.text.length==6){
        _locationFuture=getLocationData();
        //CustomLogger.debug("pincode listener exceed 5 digit now on 6");
      }
    });
  }

  Future<void> getLocationData() async{
    var data = await getCountryStateCityfromZip(_pinCode.controller.text);
    CustomLogger.debug(data);
    setState(() {
      selectedCountry = data["country"]!;
      selectedState = data["state"]!;
      selectedCity = data["city"]!;
    });
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return ListenableProvider(
      create: (_)=>DropDownOptionProvider(auth: auth),
      child: Consumer<AuthProvider>(
        builder:(context,state,child)=> Consumer<DropDownOptionProvider>(
          builder:(context,DropDownstate,child){
            return GestureDetector(
              onTap: (){
                FocusManager.instance.primaryFocus!.unfocus();
              },
              child: Scaffold(
              appBar: AppBar(
                backgroundColor: UIColor.theme_color,
                elevation: 0,
                iconTheme: IconThemeData(color: UIColor.toolbar_content_color),
                title: Text("Service details", style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: UIColor.toolbar_content_color)),),
              body: isDeleteLoading ? Center(child: CircularProgressIndicator(),) :  SingleChildScrollView(
                child: CustomMaterialBox(listOfChildren: [
                  Row(children: [
                    Expanded(child: GradientButton(text: "Edit Service",buttonInsideMaterialBox: true, onPressed: (){   setState(() {
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
                    });})),
                    SizedBox(width: 20,),
                    Expanded(child: GradientButton(text: "Delete Service", buttonInsideMaterialBox: true,colors: [UIColor.error_color,UIColor.error_color], onPressed: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Are you sure you want to delete the service?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();  // Close the dialog
                                },
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () {

                                  Navigator.of(context).pop();  // Close the dialog
                                  deleteService(state);  // Execute the confirmation action
                                },
                              ),
                            ],
                          );
                        },
                      );
                     }))
                  ],),
                  SizedBox(height: 20,),
                  ShowNonEditableTile("Service Name",widget.service.serviceName, false),
                  /*if(canEdit)*/DetailTile("Company Name", widget.service.company,controller: _companyName.controller,editable: canEdit),
                  ShowNonEditableTile("Status",widget.service.status, canEdit),

                  DetailTile("Address", widget.service.address,controller: _address.controller,editable: canEdit,big: true),

                  /* due to canEdit first time will be false thats why controller is not be able to initialize with the value so in init block we are defining the value of the controller*/
                 /* if(canEdit) */   DetailTile("Pin Code",  widget.service.pin_code,controller: _pinCode.controller,editable: canEdit,digits: true),

                  if(canEdit)FutureBuilder(future: _locationFuture, builder: (context, snapshot) {
                    return  snapshot.connectionState ==
                        ConnectionState.waiting
                        ? Container(
                      height: 80,
                    )
                        :   Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: CSCPicker(
                        flagState: CountryFlag.DISABLE,
                        showStates: true,
                        showCities: true,
                        disabledDropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 0.5, color: Colors.grey)),

                        currentCountry: selectedCountry,
                        currentCity: selectedCity,
                        currentState: selectedState,
                        dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 0.5, color: Colors.grey)),
                        onCountryChanged: (country) {
                          setState(() {
                            selectedCountry = country;
                          });
                        },
                        onStateChanged: (state) {
                          setState(() {
                            selectedState = state ?? "";
                          });
                        },
                        onCityChanged: (city) {
                          setState(() {
                            selectedCity = city ?? "";
                          });
                        },
                      ),
                    );
                  },),


                  DetailTile("Service Description", widget.service.serviceDescription,controller: _description.controller,big: true, maxLine: canEdit ? 3 :null),
                  DetailTile("Material Description", widget.service.materialDescription,controller: _material.controller),
                  DetailTile("Video Link", widget.service.videoUrl,controller: _videoUrl.controller),
                  DetailTile("Price", widget.service.price,controller: _price.controller,digits:true),
                  ShowNonEditableTile("Created Date", DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.parse(widget.service.created_at ?? "")),canEdit),


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
                  if(widget.service.imageUrls.first !=null && !canEdit)
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                          child: Text("Product Images",style: TextStyle(fontWeight: FontWeight.bold),),),
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
                                width: 60.w,height: 80,child:CachedNetworkImage(
                                placeholder: (context,url)=>Container(alignment:Alignment.center,child: const CircularProgressIndicator()),
                                imageUrl: "${APIConfig.baseUrl}/${imageUrl}/${e}",),),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),

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
                            Expanded(child:DetailTile("Pin Code", widget.service.driverDetails.pinCode,controller: _driverPinCode.controller)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child:DetailTile("House Number", widget.service.driverDetails.houseNumber,controller: _driverHouseNo.controller)),
                            Expanded(child:DetailTile("Area", widget.service.driverDetails.area,controller: _driverArea.controller)),
                          ],
                        ),Row(
                          children: [
                            Expanded(child:DetailTile("City", widget.service.driverDetails.city,controller: _driverCity.controller)),
                            Expanded(child:DetailTile("State", widget.service.driverDetails.state,controller: _driverState.controller)),
                          ],
                        ),
                        DetailTile("Landmark", widget.service.driverDetails.landmark,controller: _driverLandmark.controller),
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
                      child: isLoading?CircularProgressIndicator():GradientButton(text: "Save", onPressed: (){
                        update(state);
                      }),
                    )
                ],)),
          ),
            );}
        ),
      ),
    );
  }


  void update(AuthProvider auth)async{

    if (selectedCountry == null ||
        selectedState == null ||
        selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select Country, state and city")));
      setState(() {
        isLoading = false;
      });
      return;
    }




    setState(() {
      isLoading = true ;
    });
    CustomLogger.debug(widget.service.serviceId);
      Map<String,dynamic> data = {"id":widget.service.id,"service_id":widget.service.serviceId,
      "country" : selectedCountry,
      "city" : selectedCity,
      "state" : selectedState,
      };

      CustomLogger.debug(controllers);
      for (var i in controllers){
        if(i.controller.text.isNotEmpty){
          data[i.key]=i.controller.text;
        }
        else{
          data[i.key]=null;
        }
      }
      for(int j = 0; j<productImages.length;j++){
        if(productImages[j].network==false){
          data["pmg${j+1}"]=await MultipartFile.fromFile(productImages[j].filePath!);
        }
      }
      try{
        CustomLogger.debug(data);
       await serviceRepo.updateService(auth, widget.service.id,data);
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully Edited")));
       Navigator.pop(context);
      }
      catch(e)
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
      setState(() {
        canEdit = false;
        isLoading = false;
      });
  }




  Widget DetailTile(String header,String? body,{TextEditingController? controller,bool editable=true,bool big=false,bool digits=false, maxLine = null}){
  if(body=="" || body==null)body="Not set";
  if(!canEdit)controller?.text = body ;
  return Container(
      constraints: BoxConstraints(
        maxHeight: 40.h
      ),
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      child: TextFormField(
        keyboardType: digits ? TextInputType.number : TextInputType.text,
        controller: controller,
        maxLines:maxLine,
        decoration: InputDecoration(
            labelStyle: TextStyle(color: UIColor.hint_text_color),
          border: !(editable&&canEdit)?InputBorder.none:null,
          focusedBorder: !(editable&&canEdit)?InputBorder.none:null,
          enabledBorder: !(editable&&canEdit)?InputBorder.none:null,
          disabledBorder: !(editable&&canEdit)?InputBorder.none:null,
            labelText: header
        ),
        readOnly: !(editable&&canEdit),

      )
  );
}

  Widget ShowNonEditableTile(String header,String? body, bool inEditMode ){
   return inEditMode ? Container()
   :     Container(
       constraints: BoxConstraints(
           maxHeight: 40.h
       ),
       margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
       child: TextFormField(
         maxLines:null,
         controller: TextEditingController(text: body ?? "Not Set"),
         decoration: InputDecoration(
            labelStyle: TextStyle(color: UIColor.hint_text_color),
             border: InputBorder.none,
             focusedBorder: InputBorder.none,
             enabledBorder: InputBorder.none,
             disabledBorder: InputBorder.none,
             labelText: header
         ),
         readOnly: true,

       )
   );
  }

void deleteService(AuthProvider auth)async{
    try{
      setState(() {
        isDeleteLoading=!isDeleteLoading;
      });
    await serviceRepo.deleteService(auth, widget.service.id);
      setState(() {
        isDeleteLoading=!isDeleteLoading;
      });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service successfully deleted")));
    Navigator.pop(context);
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

}
@override
  void didUpdateWidget(covariant SingleService oldWidget) {
    super.didUpdateWidget(oldWidget);
    CustomLogger.debug("Widget reload");
  }
}
