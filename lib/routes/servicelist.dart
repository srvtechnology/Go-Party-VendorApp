import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/components/listItems.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/ServiceProvider.dart';
import 'package:utsavlife/routes/errorScreen.dart';
import 'package:collection/collection.dart';


import '../core/components/filters.dart';
import '../core/utils/UIColor.dart';

class serviceListRoute extends StatefulWidget {
  static const routeName = "/servicelist";
  const serviceListRoute({Key? key}) : super(key: key);

  @override
  State<serviceListRoute> createState() => _serviceListRouteState();
}

class _serviceListRouteState extends State<serviceListRoute> {
  String searchString = "";
  void refresh(ServiceListProvider state){
    state.getList();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_)=>ServiceListProvider(auth: Provider.of<AuthProvider>(context)),
        child: Consumer<ServiceListProvider>(builder:(context,state,child){
          if(state.isLoading){
            return Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
          if(state.services == null || state.services?.isEmpty==null){
            return errorScreenRoute(icon: Icons.account_balance_wallet_outlined, message:"Looks like you have no services added. \nAdd a service to see the list.");
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: UIColor.theme_color,
              elevation: 0,
              iconTheme: IconThemeData(color: UIColor.toolbar_content_color),
              title: Text("Services",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: UIColor.toolbar_content_color)),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Column(
                  children: [
                    ServiceFilter(onsearch: (str){
                      setState(() {
                        searchString = str;
                      });
                    }),
                    Column(
                      children: state.services!.where((element) => element.serviceName!.toLowerCase().contains(searchString.toLowerCase()) || (element.address!=null && element.address!.toLowerCase().contains(searchString.toLowerCase())) || (element.price!=null && element.price!.contains(searchString))).mapIndexed((index,e) => CustomServiceItem(service: e, index: index,state: state)).toList(),
                    )
                  ],
                ),
              ),
            )
          );
        }));
  }

}


