import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/service.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/core/provider/ServiceProvider.dart';
import 'package:utsavlife/core/repo/order.dart';
import '../../routes/singleService.dart';
import '../models/order.dart';

typedef Ontap=Function();

class CustomOrderItem extends StatefulWidget {
  Ontap? ontap;
  OrderModel order;
  bool showButtons;
  CustomOrderItem({
  Key? key,
  required this.order,
    this.ontap,
    this.showButtons=true
  }) : super(key: key);

  @override
  _CustomOrderItemState createState() => _CustomOrderItemState();
}

class _CustomOrderItemState extends State<CustomOrderItem> {
  late Color _statusColor;
  late String _statusText;
  late Color _statusTextColor;
  bool showReason = false , ShowReasonField = false;
  String selectedReason = "";
  @override
  void initState(){
    super.initState();
    choose_status();
  }
  void choose_status(){
    switch(widget.order.vendorOrderStatus){
      case VendorOrderStatus.rejected:
        _statusColor = Colors.red[700]!;
        _statusText="Rejected";
        _statusTextColor=Colors.red[100]!;
        break;
      case VendorOrderStatus.approved:
        _statusColor = Colors.greenAccent;
        _statusText="Accepted";
        _statusTextColor=Colors.green[900]!;

        break;
      default:
        _statusColor = Colors.yellowAccent;
        _statusText="Pending";
        _statusTextColor=Colors.yellow[900]!;
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ontap,
      child: Container(
        margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
        decoration:BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 3),
              color: Colors.grey[400]!,
              blurRadius: 4
            )
          ]
        ),
       width: 100.w,
       height: 25.h,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Expanded(child: Container(
             decoration: BoxDecoration(
               color: _statusColor,
               borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
             ),
             padding: EdgeInsets.symmetric(horizontal: 20),
             child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Container(child: Text(widget.order.service_name??"",style: TextStyle(color: _statusTextColor),),),
               Container(child: Text(_statusText,style: TextStyle(color: _statusTextColor),)),
             ],
           ),)),
           Expanded(flex: 4,child:
           Container(
             padding: EdgeInsets.symmetric(horizontal: 20),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.start,
               children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     Text("Amount:"),
                     Text("Date: "),
                     Text("Location: "),
                     Text("Days"),
                   ],
                 ),
                 SizedBox(width: 30.w,),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     Text("₹ ${widget.order.amount}"),
                     Text(widget.order.date),
                     Text(widget.order.address.isEmpty?"Not set":widget.order.address.substring(0,8)),
                     Text(widget.order.days),
                   ],
                 ),
               ],
             ),
           )),
           Expanded(
               child:
           ListenableProvider(
             create: (_)=>ReasonProvider(auth: Provider.of<AuthProvider>(context)),
             child: Consumer<ReasonProvider>(
               builder: (context,state,child) {
                 if (showReason==true){
                   return ReasonDialog(context, state.reasons??[]);
                 }
                 return Container(
                   padding: EdgeInsets.only(bottom: 10),
                   child: widget.showButtons?Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       if(widget.order.vendorOrderStatus == VendorOrderStatus.rejected || widget.order.vendorOrderStatus == VendorOrderStatus.pending)OutlinedButton(onPressed: (){
                          approveOrder(context, widget.order.id);
                       }, child: Text("Approve",style: TextStyle(color: Colors.green),)),
                       if(widget.order.vendorOrderStatus == VendorOrderStatus.approved || widget.order.vendorOrderStatus == VendorOrderStatus.pending)OutlinedButton(onPressed: (){
                          rejectOrder(context);
                       }, child: Text("Reject",style: TextStyle(color: Colors.red))),
                     ],
                   ):Container(),
                 );
               }
             ),
           )
           )
         ],
       )
      ),
    );
  }
  void approveOrder(BuildContext context,String id)async{
    try {
      ChangeOrderStatus(Provider.of<AuthProvider>(context), VendorOrderStatus.approved, id, "");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Approved")));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

  }
  void rejectOrder(BuildContext context)async{
     setState(() {
      showReason = true;
    });
  }
  Widget ReasonDialog(BuildContext context,List<String> rejectReasons){
    return Container(
      height: 40.h,
      child: SingleChildScrollView(
        child: Column(
            children: [
              ...rejectReasons.map((e) => ListTile(
                leading:
                Radio(
                    value: e,
                    groupValue: selectedReason,
                    onChanged: (value){
                      setState(() {
                        selectedReason = value! ;
                        ShowReasonField = false;
                      });
                    }
                ),
                title: Text(e),
              )
              ),
              ListTile(
                title: Text("Other"),
                leading: Radio(
                  autofocus: true,
                  onChanged: (val){
                    setState(() {
                      selectedReason ="";
                      ShowReasonField = true;
                    });
                  },
                  value: "Other",
                  groupValue: selectedReason,
                ),
              ),
              if(ShowReasonField)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    onChanged: (text){
                      setState(() {
                        selectedReason = text ;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

                    ),
                  ),
                ),
              SizedBox(height: 0,),
              OutlinedButton(onPressed: (){
                try {
                  if(selectedReason==""){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select a Reason")));
                  }
                  else{context.read<SingleOrderProvider>().change_status(
                      VendorOrderStatus.rejected, selectedReason);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Order Rejected")));
                  setState(() {
                    showReason=false;
                  });
                  }
                }catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }, child: Text("Submit"))
            ]
        ),
      ),
    );
  }


}

class CustomServiceItem extends StatelessWidget {
  int index;
  ServiceModel service;
  ServiceListProvider state;
  CustomServiceItem({Key? key,required this.index,required this.service,required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleService(service: service,))).then((value) => state.getList());
      },
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 16.sp,color: Colors.black),
        child: Container(
            margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
            decoration:BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3),
                      color: Colors.grey[400]!,
                      blurRadius: 4
                  )
                ]
            ),
            width: 100.w,
            height: 20.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text("${(index+1)}",style: TextStyle(color: Colors.white),),
                      ),
                      Text(service.address!.substring(0,min(service.address!.length,10)),style: TextStyle(color: Colors.white),)
                    ],
                  ),
                  )),
                Expanded(flex: 3,child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 20.w,child: Text("Name:")),
                          SizedBox(width: 10.w,),
                          SizedBox(width: 30.w,child:Text(service.serviceName??"Not Set")),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 20.w,child:Text("Price:")),
                          SizedBox(width: 10.w,),
                          SizedBox(width: 30.w,child:Text(service.price??"Not Set")),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            )
        ),
      ),
    );
  }
}
