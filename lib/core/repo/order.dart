import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';

Future<List<OrderModel>> get_upcoming_order_list(AuthProvider auth)async{
  Response response;
  List<OrderModel> orders = [] ;
  try{
      response = await Dio().get("${APIConfig.baseUrl}/api/upcoming-order",
      options: Options(
        headers: {
          "Authorization":"Bearer ${auth.token}"
        }
      )
      );
          for(var order in response.data["data"]){
            orders.add(OrderModel.fromJson(order));
          }
          return orders;
        }
   catch(e){
          return Future.error(e);
        }
}

Future<OrderModel> get_orderById(AuthProvider auth,String id)async{
  Response response;
  List<OrderModel> orders = [] ;
  try{
    response = await Dio().get("${APIConfig.baseUrl}/api/details-order/${id}",
        options: Options(
            headers: {
              "Authorization":"Bearer ${auth.token}"
            }
        )
    );
    return OrderModel.fromJson(response.data["data"]);
  }
  catch(e){
    print(e);
    return Future.error(e);
  }
}