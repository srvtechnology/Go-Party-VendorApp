import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/utils/UIColor.dart';
typedef onSearch = Function(String searchItem) ;
typedef onStatusSelect = Function(VendorOrderStatus? status);
class Filter extends StatefulWidget {
  onSearch onsearch ;
  onStatusSelect onstatusSelect ;
  Filter({super.key,required this.onsearch,required this.onstatusSelect});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  String selectedStatus="All";
  List statuses = [
    "All",
    "Rejected",
    "Accepted"
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      height: 15.h,
        child: Row(children: [
          Expanded(flex: 3,child: _SearchBar(context)),
          Expanded(child: Container(),),
          Expanded(flex:2,child: _statusFilter(context),),
        ]),
    );
  }
  Widget _statusFilter(BuildContext context){
    return Container(
      alignment: Alignment.center,
      width: 40.w,
      child: DropdownButton(
        isExpanded: true,
        value: selectedStatus,
        items: statuses.map((e) => DropdownMenuItem(value:e, child: Text(e,style: TextStyle(fontSize: 15.sp),))).toList(), onChanged: (ob){
          setState(() {
            selectedStatus = ob.toString();
          });
          if(ob==statuses[0]){
            widget.onstatusSelect(null);
          }
          else if(ob==statuses[1]){
            widget.onstatusSelect(VendorOrderStatus.rejected);
          }
          else{
            widget.onstatusSelect(VendorOrderStatus.approved);
          }
      }),
    );
  }
  Widget _SearchBar(BuildContext context){
    return Container(
      height: 35,
      decoration:const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      margin:const EdgeInsets.symmetric(horizontal: 5),
    child: TextFormField(
      onChanged: (text){
        widget.onsearch(text);
      },
      decoration:const InputDecoration(
        contentPadding: EdgeInsets.only(bottom: 5,left: 5),
        icon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    ),
    );
  }
}





class Filter2 extends StatefulWidget {
  onSearch onsearch ;
  onStatusSelect onstatusSelect ;
  Filter2({super.key,required this.onsearch,required this.onstatusSelect});

  @override
  State<Filter2> createState() => _Filter2State();
}

class _Filter2State extends State<Filter2> {
  String selectedStatus="All";
  List statuses = [
    "All",
    "Accepted",
    "Pending"
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 15.h,
      child: Row(children: [
        Expanded(flex: 3,child: _SearchBar(context)),
        Expanded(child: Container(),),
        Expanded(flex:2,child: _statusFilter(context),),
      ]),
    );
  }
  Widget _statusFilter(BuildContext context){
    return Container(
      alignment: Alignment.center,
      width: 40.w,
      child: DropdownButton(
          isExpanded: true,
          value: selectedStatus,
          items: statuses.map((e) => DropdownMenuItem(value:e, child: Text(e,style: TextStyle(fontSize: 15.sp)))).toList(), onChanged: (ob){
        setState(() {
          selectedStatus = ob.toString();
        });
        if(ob==statuses[0]){
          widget.onstatusSelect(null);
        }
        else if(ob==statuses[1]){
          widget.onstatusSelect(VendorOrderStatus.approved);
        }
        else{
          widget.onstatusSelect(VendorOrderStatus.pending);
        }
      }),
    );
  }
  Widget _SearchBar(BuildContext context){
    return Container(
      height: 35,
      decoration:const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      margin:const EdgeInsets.symmetric(horizontal: 5),
      child: TextFormField(
        onChanged: (text){
          widget.onsearch(text);
        },
        decoration:const InputDecoration(
          contentPadding: EdgeInsets.only(left: 5,bottom: 5),
          icon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}




class ServiceFilter extends StatefulWidget {
  onSearch onsearch ;
  ServiceFilter({super.key,required this.onsearch});

  @override
  State<ServiceFilter> createState() => _ServiceFilterState();
}

class _ServiceFilterState extends State<ServiceFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      height: 10.h,
      child: Row(children: [
        Expanded(flex: 3,child: _SearchBar(context)),
      ]),
    );
  }
  Widget _SearchBar(BuildContext context){
    return Container(
      margin:const EdgeInsets.symmetric(horizontal: 5),
      child: TextFormField(
        onChanged: (text){
          widget.onsearch(text);
        },
        decoration: InputDecoration(
         hintText: "Search here",
          hintStyle: TextStyle(color: UIColor.hint_text_color, fontSize: 14, fontWeight: FontWeight.normal),
          suffixIcon: Icon(Icons.search, color: UIColor.theme_color,),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.grey.shade300,  // Outline color for the border
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: UIColor.theme_color.withAlpha(99),  // Outline color for the border
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.grey.shade300,  // Outline color for the border
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}