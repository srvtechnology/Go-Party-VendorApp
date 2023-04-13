import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/service.dart';

class SingleService extends StatefulWidget {
  final serviceModel service;
  SingleService({Key? key,required this.service}) : super(key: key);

  @override
  State<SingleService> createState() => _SingleServiceState();
}

class _SingleServiceState extends State<SingleService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order details"),),
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
                  Container(
                    height: 5.h,
                    margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Text("${widget.service.serviceName}",style: Theme.of(context).textTheme.headlineSmall,),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                    child: Text("General Information",style: Theme.of(context).textTheme.bodyMedium,),
                  ),
                  DetailTile("Description", widget.service.serviceDescription),
                  DetailTile("Address", widget.service.address),
                  Row(
                  children: [
                  Expanded(child:DetailTile("Price", widget.service.price)),
                  Expanded(child:DetailTile("Price basis", widget.service.priceBasis)),
                  ],
                  ),
                  DetailTile("Discounted Price", widget.service.discountedPrice),
                  SizedBox(height: 20,),
                  Container(
                  margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                  child: Text("Category Details",style: Theme.of(context).textTheme.bodyMedium,),
                  ),
                  Row(
                    children: [
                      Expanded(child:DetailTile("Category", widget.service.categoryName)),
                      Expanded(child:DetailTile("Description", widget.service.categoryDescription)),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Container(
                  margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                  child: Text("Driver Details",style: Theme.of(context).textTheme.bodyMedium,),
                  ),
                  Row(
                  children: [
                      Expanded(child:DetailTile("Name", widget.service.driverDetails.name)),
                      Expanded(child:DetailTile("Mobile number", widget.service.driverDetails.mobileNumber)),
                  ],
                  ),
                  Row(
                  children: [
                  Expanded(child:DetailTile("KYC Type", widget.service.driverDetails.kycType)),
                  Expanded(child:DetailTile("KYC number", widget.service.driverDetails.kycNumber)),
                  ],
                  ),
                  Row(
                  children: [
                  Expanded(child:DetailTile("License Number", widget.service.driverDetails.licenseNumber)),
                  Expanded(child:DetailTile("Pin Code", widget.service.driverDetails.pinCode)),
                  ],
                  ),
                  Row(
                  children: [
                  Expanded(child:DetailTile("House Number", widget.service.driverDetails.houseNumber)),
                  Expanded(child:DetailTile("Area", widget.service.driverDetails.area)),
                  ],
                  ),Row(
                  children: [
                  Expanded(child:DetailTile("City", widget.service.driverDetails.city)),
                  Expanded(child:DetailTile("State", widget.service.driverDetails.state)),
                  ],
                  ),
                ],
              ),
            ))
    );
  }
  Widget DetailTile(String header,String? body){
  if(body=="" || body==null)body="Not set";
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: header
        ),
        initialValue: body,
        readOnly: true,
      )
  );
}
}
