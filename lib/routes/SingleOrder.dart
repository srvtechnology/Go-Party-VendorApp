import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';

class SingleOrderPage extends StatefulWidget {
  String id;
  bool readOnly;
  SingleOrderPage({Key? key,required this.id,required this.readOnly}) : super(key: key);

  @override
  State<SingleOrderPage> createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
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
                        height: 5.h,
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                        child: Text("₹ ${singleOrderState.order!.amount}",style: Theme.of(context).textTheme.headlineSmall,),
                      ),
                      SizedBox(height: 20,),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                        child: Text("General Information",style: Theme.of(context).textTheme.bodyMedium,),
                      ),
                      Row(
                        children: [
                          Expanded(child: DetailTile("Status", singleOrderState.order!.vendorOrderStatus == VendorOrderStatus.approved?"Approved":"Rejected")),
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
                      )
                    ],
                  ),
                );

              },
            ),
          ),
        bottomNavigationBar:
        (!widget.readOnly)
            ?
    Consumer<SingleOrderProvider>(
    builder: (context,singleOrderState,child)
    {
      if(singleOrderState.order == null)
        {
          return CircularProgressIndicator();
        }
      return BottomAppBar(
            elevation: 0.5,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment:MainAxisAlignment.spaceEvenly,
              children: [
                if(singleOrderState.order?.vendorOrderStatus == VendorOrderStatus.rejected || singleOrderState.order?.vendorOrderStatus == VendorOrderStatus.pending)
                BottomButton(context:context,onPressed: ()=>approveOrder(context),text: "Approve",primaryColor: Colors.green),
                if(singleOrderState.order?.vendorOrderStatus == VendorOrderStatus.approved || singleOrderState.order?.vendorOrderStatus == VendorOrderStatus.pending)
                BottomButton(context:context,onPressed: () => rejectOrder(context),text: "Reject",primaryColor: Colors.red),
              ],
            ),
        );
    }
          )
      :
        null,
      ),
    );
  }
  void approveOrder(BuildContext context)async{
    try {
      await context.read<SingleOrderProvider>().change_status(
          VendorOrderStatus.approved);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Approved")));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    
  }
  void rejectOrder(BuildContext context){
  try {
    context.read<SingleOrderProvider>().change_status(
        VendorOrderStatus.rejected);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Rejected")));
  }
  catch(e){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }
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
          labelText: header
        ),
        initialValue: body,
        readOnly: true,
      )
    );
  }
}
