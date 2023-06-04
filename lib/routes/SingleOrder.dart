import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:search_choices/search_choices.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';

class SingleOrderPage extends StatefulWidget {
  String id;
  bool readOnly;
  SingleOrderPage({Key? key,required this.id,required this.readOnly}) : super(key: key);

  @override
  State<SingleOrderPage> createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
  String selectedReason = "";
  bool ShowReasonField = false;
  bool showReason = false;
  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return ListenableProvider(
      create: (_)=>SingleOrderProvider(id: widget.id,auth: auth),
      builder:(context,child)=>Scaffold(
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
          child: Consumer<SingleOrderProvider>(
              builder: (context,singleOrderState,child){
                if(singleOrderState.isLoading){
                  return Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
                }
                if(singleOrderState.isLoading==false && singleOrderState.order==null)
                 {
                   return Container(
                     alignment: Alignment.center,
                     child: Text("Error fetching data.Please check logs"),
                   );
                 }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 6.h,
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Text("₹ ${singleOrderState.order!.amount}",style: Theme.of(context).textTheme.headlineSmall,),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                            child: Text("General Information",style: Theme.of(context).textTheme.bodyMedium,),
                          ),
                          Row(
                            children: [
                              Expanded(child: DetailTile("Status", singleOrderState.order!.vendorOrderStatus == VendorOrderStatus.approved?"Accepted":singleOrderState.order!.vendorOrderStatus == VendorOrderStatus.pending?"Pending":"Rejected")),
                              Expanded(child: DetailTile("Category", singleOrderState.order!.category!)),
                            ],
                          ),
                          DetailTile("Service Name", singleOrderState.order!.service_name!),
                          DetailTile("Address", singleOrderState.order!.address!),
                          Row(
                            children: [
                              Expanded(child:DetailTile("Order start date", singleOrderState.order!.date!)),
                              Expanded(child:DetailTile("Order end date", singleOrderState.order!.end_date!)),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: DetailTile("Time", singleOrderState.order!.timing!)),
                              Expanded(child: DetailTile("Days", singleOrderState.order!.days)),
                            ],
                          ),
                          SizedBox(height: 10,),
                          if(singleOrderState.order?.customer!=null)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                            child: Text("Customer Information",style: Theme.of(context).textTheme.bodyMedium,),
                          ),
                          Row(
                            children: [
                              Expanded(child:DetailTile("Name", singleOrderState.order!.customer?.name??"Not Set")),
                              if(singleOrderState.order?.vendorOrderStatus==VendorOrderStatus.approved)
                              Expanded(child:DetailTile("email", singleOrderState.order!.customer?.email??"Not Set")),
                            ],
                          ),
                        ],
                    )
                );

              },
            ),
          ),
        bottomNavigationBar:
        (!widget.readOnly)
            ?
    ListenableProvider(
      create: (_)=>ReasonProvider(auth: auth),
      child: Consumer2<SingleOrderProvider,ReasonProvider>(
      builder: (context,singleOrderState,reasonState,child)
      {
        CustomLogger.debug(showReason);
        if (showReason==true){
          return ReasonDialog(context, reasonState.reasons??[]);
        }
        if(singleOrderState.order == null)
          {
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          }
        return BottomAppBar(
              elevation: 0.5,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                children: [
                  if(singleOrderState.order?.vendorOrderStatus == VendorOrderStatus.rejected || singleOrderState.order?.vendorOrderStatus == VendorOrderStatus.pending)
                  BottomButton(context:context,onPressed: ()=>approveOrder(context),text: "Accept",primaryColor: Colors.green),
                  if(singleOrderState.order?.vendorOrderStatus == VendorOrderStatus.approved || singleOrderState.order?.vendorOrderStatus == VendorOrderStatus.pending)
                  BottomButton(context:context,onPressed: () => rejectOrder(context,reasonState.reasons??[]),text: "Reject",primaryColor: Colors.red),
                ],
              ),
          );
      }
            ),
    )
      :
        null,
      ),
    );
  }
  void approveOrder(BuildContext context)async{
    try {
      await context.read<SingleOrderProvider>().change_status(
          VendorOrderStatus.approved,"");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Accepted")));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    
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

  void rejectOrder(BuildContext context,List<String> rejectReasons)async{
    setState(() {
      showReason = true;
    });

  }

  Widget BottomButton({required BuildContext context,Function()? onPressed,required String text,required Color primaryColor}){
    return  OutlinedButton(
        style: OutlinedButton.styleFrom(side: BorderSide(width: 1,color: primaryColor)),
        onPressed: onPressed,
        child: Text(text,style: TextStyle(color: primaryColor),));

  }

  Widget DetailTile(String header,String body){
    if(body=="")body="Not set";
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: header,
          border: InputBorder.none
        ),
        initialValue: body,
        readOnly: true,
      )
    );
  }
}
