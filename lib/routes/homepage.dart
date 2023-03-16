import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/drawer.dart';
import 'package:utsavlife/core/components/filters.dart';
import 'package:utsavlife/core/components/listItems.dart';
import 'package:utsavlife/core/components/nav.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/routes/SingleOrder.dart';
import 'package:utsavlife/routes/notifications.dart';

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
    const Orders(),
    const History(),
    const Profile(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>UpcomingOrderProvider(
            auth: Provider.of<AuthProvider>(context)
          )),
          ChangeNotifierProvider(create: (_)=>HistoryOrderProvider(
              auth: Provider.of<AuthProvider>(context)
          )),
        ],
        builder:(context,args)=> Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(onPressed: (){
                Navigator.pushNamed(context, NotificationPage.routeName);
              }, icon:const Icon(Icons.notifications))
            ],
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
        ),
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
  bool editMode = false ;
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder:(context,auth,child)=>Container(
          height: double.infinity,
          width: double.infinity,
          padding:const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                      _ProfileHeader(context,auth.user!.name,auth.user!.email),
                      IconButton(onPressed: (){
                        setState(() {
                          editMode = !editMode;
                        });
                      }, icon: Icon(Icons.edit,color: editMode?Theme.of(context).primaryColor:null),),
                      _CustomText(context, title: "Email",content: auth.user!.email),
                      _CustomText(context, title: "Name",content: auth.user!.name),
                      _CustomText(context, title: "Phone",content: auth.user!.mobileno??"Not set"),
                      _CustomText(context, title: "Country",content: auth.user!.country??"Not set"),
                      _CustomText(context, title: "State",content: auth.user!.state??"Not set"),
                      _CustomText(context, title: "City",content: auth.user!.city??"Not set"),
                        if(editMode)
                          Container(
                            alignment: Alignment.center,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
                              ),
                              onPressed: () {  },
                              child: Text("Save"),
                            ),
                          ),
                  ]),
                ),
              ),

            ],
          ),
      ),
    );
  }

  Widget _CustomText(BuildContext context,{required String title,required String content}){
    return Container(
      margin:const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin:const EdgeInsets.symmetric(vertical: 5),child: Text(title,style:const TextStyle(fontWeight: FontWeight.bold),)),
          Container(margin:const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                decoration: editMode?InputDecoration(border: const OutlineInputBorder()):InputDecoration(border: InputBorder.none),
                readOnly: !editMode,
                initialValue: content,
              )),
        ],
      ),
      );
  }
  Widget _ProfileHeader(BuildContext context,String name,String email){
    return Container(
      margin: const EdgeInsets.all(10),
        child: Row(
          children: [
             const Expanded(
               flex: 3,
               child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 40,
                child: CircleAvatar(backgroundColor: Colors.black,child: Icon(Icons.person),),
            ),
             ),
            Expanded(flex:6,child: Container(
              margin:const EdgeInsets.only(left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,style: Theme.of(context).textTheme.headlineSmall,),
                  Text(email,),
                ],
              ),
            ))
          ],
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
  void refresh(BuildContext context){
    context.read<HistoryOrderProvider>().load_history_orders();
  }
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
                Expanded(flex:4,child: Text("Amount"),),
                Expanded(flex:4,child: Text("Date"),),
                Expanded(flex:4,child: Text("Location"),),
                Expanded(flex:4,child: Text("Days",textAlign: TextAlign.center,),),
                Expanded(child: Text(""),),
                    ],),
            ),
          ),
          Expanded(flex: 8,child: Consumer<HistoryOrderProvider>(
            builder: (context,orderState,child){
              if(orderState.isLoading){
                return Container(
                  alignment: Alignment.topCenter,
                  child:const CircularProgressIndicator(),
                );
              }
              else if(orderState.orders.isEmpty){
                return Container(
                  margin: EdgeInsets.all(10),
                  child: Text("No History"),
                );
              }
              return SingleChildScrollView(
                child: Column(
                    children: orderState.orders.map((e) => CustomOrderItem(order: e,ontap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleOrderPage(id:e.id,readOnly: true,))).then((value) => refresh(context));
                    },)).toList()),
              );
            },
          ))

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
  void refresh(BuildContext context){
    context.read<UpcomingOrderProvider>().load_upcoming_orders();
  }
  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding:const EdgeInsets.all(10),
      child: Column(children: [
        const Expanded(child: Filter()),
        Expanded(
          child: Container(
            margin:const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
            child: Row(children:const [
              Expanded(flex:4,child: Text("Amount"),),
              Expanded(flex:4,child: Text("Date"),),
              Expanded(flex:4,child: Text("Location"),),
              Expanded(flex:2,child: Text("Days",textAlign: TextAlign.center,),),
              Expanded(flex:3,child: Text(""),),
            ],),
          ),
        ),
        Expanded(flex: 8,child: Consumer<UpcomingOrderProvider>(
          builder: (context,orderState,child){
            if(orderState.isLoading){
              return Container(
                alignment: Alignment.topCenter,
                child:const CircularProgressIndicator(),
              );
            }
            else if(orderState.orders.isEmpty){
              return Container(
                margin: EdgeInsets.all(10),
                child: Text("No upcoming orders"),
              );
            }
            return SingleChildScrollView(
              child: Column(
                  children: orderState.orders.map((e) => CustomOrderItem(order: e,ontap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleOrderPage(id:e.id,readOnly: false,))).then((value) => refresh(context));
                  },)).toList()),
            );
          },
        ))
      ]),
    );
  }
}