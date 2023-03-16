import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/order.dart';
typedef Ontap=Function();

class CustomOrderItem extends StatefulWidget {
  Ontap? ontap;
  OrderModel order;
  CustomOrderItem({
  Key? key,
           this.ontap,
  required this.order,
  }) : super(key: key);

  @override
  _CustomOrderItemState createState() => _CustomOrderItemState();
}

class _CustomOrderItemState extends State<CustomOrderItem> {
  late Color _statusColor;
  late String _statusText;
  @override
  void initState(){
    super.initState();
    choose_status();
  }
  void choose_status(){
    switch(widget.order.vendorOrderStatus){
      case VendorOrderStatus.rejected:
        _statusColor = Colors.red;
        _statusText="Rejected";
        break;
      case VendorOrderStatus.approved:
        _statusColor = Colors.green;
        _statusText="Approved";
        break;
      default:
        _statusColor = Colors.yellow;
        _statusText="Pending";
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ontap,
      child: Container(
        margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
        decoration:const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(2, 2),
              color: Colors.grey,
              blurRadius: 2
            )
          ]
        ),
       width: 100.w,
       height: 8.h,
       child: Row(children: [
          Expanded(flex:4,child: Text(widget.order.amount,textAlign: TextAlign.center,)),
          Expanded(flex:4,child: Text(widget.order.date,style: TextStyle(fontSize: 12.sp),)),
          Expanded(flex:4,child: Text(widget.order.address)),
          Expanded(flex:2,child: Text(widget.order.days,textAlign: TextAlign.center,),),
          Expanded(flex:3,child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_statusText),
              Container(margin: EdgeInsets.only(left: 10,top: 10,right: 10),height: 10,decoration: BoxDecoration(color: _statusColor),),
            ],
          ))
       ]),
      ),
    );
  }
}