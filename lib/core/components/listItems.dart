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
  @override
  void initState(){
    super.initState();
    choose_statusColor();
  }
  void choose_statusColor(){
    switch(widget.order.vendorOrderStatus){
      case VendorOrderStatus.rejected:
        _statusColor = Colors.red;
        break;
      case VendorOrderStatus.approved:
        _statusColor = Colors.green;
        break;
      default:
        _statusColor = Colors.yellow;
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
          Expanded(flex:4,child: Text(widget.order.days,textAlign: TextAlign.center,),),
          Expanded(child: Container(margin: EdgeInsets.only(left: 10,top: 10),height: 10,decoration: BoxDecoration(color: _statusColor),))
       ]),
      ),
    );
  }
}