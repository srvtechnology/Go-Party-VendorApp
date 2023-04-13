import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/service.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/ServiceProvider.dart';
import 'package:utsavlife/routes/singleService.dart';

class serviceListRoute extends StatefulWidget {
  static const routeName = "/servicelist";
  const serviceListRoute({Key? key}) : super(key: key);

  @override
  State<serviceListRoute> createState() => _serviceListRouteState();
}

class _serviceListRouteState extends State<serviceListRoute> {
  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
        create: (_)=>ServiceListProvider(auth: Provider.of<AuthProvider>(context)),
        child: Consumer<ServiceListProvider>(builder:(context,state,child){
          if(state.isLoading){
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Column(
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.sp,color: Colors.black54),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20,top: 10),
                        child: Row(
                          children: [
                            Expanded(child: Text("Name",textAlign: TextAlign.center,)),
                            Expanded(child: Text("Address",textAlign: TextAlign.center,)),
                            Expanded(child: Text("Category")),
                            Expanded(child: Text("Price")),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: state.services!.map((e) => listItem(e)).toList(),
                    )
                  ],
                ),
              ),
            )
          );
        }));
  }
  Widget listItem(serviceModel service){
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleService(service: service,)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(3,3),
                color: Colors.grey[400]!,
                blurRadius: 3
            ),
          ],
            borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(child: Text(service.serviceName!,textAlign: TextAlign.center,softWrap: true,)),
            Expanded(child: Text(service.address!,textAlign: TextAlign.center,)),
            Expanded(child: Text(service.categoryName!)),
            Expanded(child: Text(service.price!)),
          ],
        ),
      ),
    );
  }
}
