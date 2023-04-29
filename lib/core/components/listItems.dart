import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/order.dart';
typedef Ontap=Function();

class CustomOrderItem extends StatefulWidget {
  Ontap? ontap;
  OrderModel order;
  bool showButtons;
  CustomOrderItem({
  Key? key,
           this.ontap,
  required this.order,
    this.showButtons=true
  }) : super(key: key);

  @override
  _CustomOrderItemState createState() => _CustomOrderItemState();
}

class _CustomOrderItemState extends State<CustomOrderItem> {
  late Color _statusColor;
  late String _statusText;
  late Color _statusTextColor;

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
        _statusText="Approved";
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
       height: 30.h,
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
               Container(child: Text(""),),
               Container(child: Text(_statusText,style: TextStyle(color: _statusTextColor),)),
             ],
           ),)),
           Expanded(flex: 4,child: Container(
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     Text(widget.order.amount),
                     Text(widget.order.date),
                     Text(widget.order.address.isEmpty?"Not set":widget.order.address.substring(0,15)),
                     Text(widget.order.days),
                   ],
                 ),
               ],
             ),
           )),
           Expanded(child: Container(
             padding: EdgeInsets.only(bottom: 10),
             child: widget.showButtons?Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 if(widget.order.vendorOrderStatus == VendorOrderStatus.rejected || widget.order.vendorOrderStatus == VendorOrderStatus.pending)OutlinedButton(onPressed: (){}, child: Text("Approve",style: TextStyle(color: Colors.green),)),
                 if(widget.order.vendorOrderStatus == VendorOrderStatus.approved || widget.order.vendorOrderStatus == VendorOrderStatus.pending)OutlinedButton(onPressed: (){}, child: Text("Reject",style: TextStyle(color: Colors.red))),
               ],
             ):Container(),
           ))
         ],
       )
      ),
    );
  }
}