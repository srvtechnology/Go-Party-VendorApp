import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/drawer.dart';
import 'package:utsavlife/core/components/filters.dart';
import 'package:utsavlife/core/components/listItems.dart';
import 'package:utsavlife/core/components/nav.dart';

class Homepage extends StatefulWidget {
  static const routeName = "home";
  const Homepage({ Key? key }) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int index=0;
  final _drawerKey = GlobalKey();
  List<Widget> items = [
    const Profile(),
    const History(),
    const Orders(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
        body: items[index],
        drawer: CustomDrawer(
            key: _drawerKey,

        ),
        bottomNavigationBar:CustomBottomNavBar(
          index: index,
          ontap: (i){
            setState(() {
              index = i;
            });
          },
        ),
    );
  }
}


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        padding:const EdgeInsets.all(10),
        child: Column(children: [
            _ProfileHeader(context),
            _CustomText(context, title: "Email",content: "User10@gmail.com"),
            _CustomText(context, title: "Username",content: "User10"),
            _CustomText(context, title: "Designation",content: "Designation"),
        ]),
    );
  }

  Widget _CustomText(BuildContext context,{required String title,required String content}){
    return Container(
      margin:const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin:const EdgeInsets.symmetric(vertical: 5),child: Text(title,style: Theme.of(context).textTheme.headlineSmall,)),
          Container(margin:const EdgeInsets.symmetric(vertical: 5),child: Text(content)),
        ],
      ),
      );
  }
  Widget _ProfileHeader(BuildContext context){
    return Container(
      margin: const EdgeInsets.all(10),
        child: const CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 50,
          child: CircleAvatar(backgroundColor: Colors.black,child: Icon(Icons.person),),
        ),
    );
  }
}

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        padding:const EdgeInsets.all(10),
        child: Column(children: [
          Expanded(child: Filter()),
          Expanded(
            child: Container(
              margin:const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
              child: Row(children:const [
              Expanded(flex:4,child: Text("Title"),),
              Expanded(flex:4,child: Text("Date"),),
              Expanded(flex:4,child: Text("Amount"),),
              Expanded(flex:4,child: Text("Location"),),
              Expanded(child: Text(""),),
                    ],),
            ),
          ),
          Expanded(flex: 8,child: SingleChildScrollView(child: Column(children: [
          CustomOrderItem(title: "Test",date: "10-10-2021",amount: "3000",location: "Kolkata",status: Colors.red,),
          CustomOrderItem(title: "Test",date: "10-10-2021",amount: "3000",location: "Kolkata",status: Colors.green,),
          CustomOrderItem(title: "Test",date: "10-10-2021",amount: "3000",location: "Kolkata",status: Colors.yellow,),
          CustomOrderItem(title: "Test",date: "10-10-2021",amount: "3000",location: "Kolkata",status: Colors.red,),  
          ]),))
        ]),
    );
  }
}

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding:const EdgeInsets.all(10),
      child: Column(children: [
        Row(children:const [
          Expanded(child: Text("Title"),),
          Expanded(child: Text("Date"),),
          Expanded(child: Text("Amount"),),
          Expanded(child: Text("Location"),),
        ],)

      ]),  
    );
  }
}