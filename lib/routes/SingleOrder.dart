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
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailTile("Status", singleOrderState.order!.vendorOrderStatus == VendorOrderStatus.approved?"Approved":"Rejected"),
                    DetailTile("Category", singleOrderState.order!.category!),
                    DetailTile("Service Name", singleOrderState.order!.service_name!),
                    DetailTile("Address", singleOrderState.order!.address!),
                    DetailTile("Order start date", singleOrderState.order!.date!),
                    DetailTile("Order end date", singleOrderState.order!.end_date!),
                    DetailTile("Time", singleOrderState.order!.timing!),
                    DetailTile("Days", singleOrderState.order!.days),
                    DetailTile("Amount", singleOrderState.order!.amount),
                  ],
                );

              },
            ),
          ),
        ),
        bottomNavigationBar:
        (!widget.readOnly)
            ?
          BottomAppBar(
          elevation: 0.5,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            children: [
              BottomButton(context:context,onPressed: ()=>context.read<SingleOrderProvider>().change_status(VendorOrderStatus.approved),text: "Approve",primaryColor: Colors.green),
              BottomButton(context:context,onPressed: () => context.read<SingleOrderProvider>().change_status(VendorOrderStatus.rejected),text: "Reject",primaryColor: Colors.red),
            ],
          ),
        )
      :
        null,
      ),
    );
  }

  Widget BottomButton({required BuildContext context,Function()? onPressed,required String text,required Color primaryColor}){
    return  OutlinedButton(
        style: OutlinedButton.styleFrom(side: BorderSide(width: 1,color: primaryColor)),
        onPressed: onPressed,
        child: Text(text,style: TextStyle(color: primaryColor),));

  }
  Widget DetailTile(String header,String body){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
        Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(header,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.sp),)),
        Text(body)
        ]
      ),
    );
  }
}
