import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
typedef Ontap=Function();

class CustomOrderItem extends StatefulWidget {
  Ontap? ontap;
  String title;
  String date;
  String amount;
  String location;
  Color status;
  CustomOrderItem({ 
  Key? key,this.ontap,
  required this.title,
  required this.date,
  required this.amount,
  required this.location,
  required this.status,
  }) : super(key: key);

  @override
  _CustomOrderItemState createState() => _CustomOrderItemState();
}

class _CustomOrderItemState extends State<CustomOrderItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ontap,
      child: Container(
        margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
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
       height: 7.h,
       child: Row(children: [
          Expanded(flex:4,child: Text(widget.title,textAlign: TextAlign.center,)),
          Expanded(flex:4,child: Text(widget.date,style: TextStyle(fontSize: 12.sp),)),
          Expanded(flex:4,child: Text(widget.amount)),
          Expanded(flex:4,child: Text(widget.location)),
          Expanded(child: Container(height: 10,decoration: BoxDecoration(color: widget.status),))
       ]),
      ),
    );
  }
}