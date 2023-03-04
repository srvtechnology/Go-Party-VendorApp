import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  List statuses = [
    "All",
    "Upcoming",
    "Rejected",
    "Completed"
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
      width: 20,
      child: DropdownButton(
        isExpanded: true,
        value: statuses[0],
        items: statuses.map((e) => DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (ob){}),
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
      decoration:const InputDecoration(
        icon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    ),
    );
  }
}