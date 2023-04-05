import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/order.dart';
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
    "Approved"
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.h,
        child: Row(children: [
          Expanded(flex: 2,child: _SearchBar(context)),  
          Expanded(child: Container(),),
          Expanded(child: _statusFilter(context),),
        ]),
    );
  }
  Widget _statusFilter(BuildContext context){
    return Container(
      alignment: Alignment.center,
      width: 20,
      child: DropdownButton(
        isExpanded: true,
        value: selectedStatus,
        items: statuses.map((e) => DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (ob){
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
      height: 30,
      decoration:const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      margin:const EdgeInsets.symmetric(horizontal: 5),
    child: TextFormField(
      onChanged: (text){
        widget.onsearch(text);
      },
      decoration:const InputDecoration(
        icon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    ),
    );
  }
}