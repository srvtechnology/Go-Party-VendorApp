import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';

Future<List<OrderModel>> get_upcoming_order_list(AuthProvider auth)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  List<OrderModel> orders = [] ;
  try{
      response = await dio.get("${APIConfig.baseUrl}/api/upcoming-order",
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
      print(e);
          return Future.error(e);
        }
}
Future<List<OrderModel>> get_history_order_list(AuthProvider auth)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  List<OrderModel> orders = [] ;
  try{
      response = await dio.get("${APIConfig.baseUrl}/api/history-order",
      options: Options(
        headers: {
          "Authorization":"Bearer ${auth.token}"
        }
      )
      );
      print(response.data);
          for(var order in response.data["data"]){
            orders.add(OrderModel.fromJson(order));
          }
          return orders;
        }
   catch(e){
      print(e);
          return Future.error(e);
        }
}

Future<OrderModel> get_orderById(AuthProvider auth,String id)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  List<OrderModel> orders = [] ;
  try{
    response = await dio.get("${APIConfig.baseUrl}/api/details-order/${id}",
        options: Options(
            headers: {
              "Authorization":"Bearer ${auth.token}"
            }
        )
    );
    print(response.data);
    return OrderModel.fromJson(response.data["data"]);
  }
  catch(e){
    print(e);
    return Future.error(e);
  }
}

Future<String> ChangeOrderStatus(AuthProvider auth,VendorOrderStatus status,String OrderId) async
{
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  try{
    String url;
    if(status == VendorOrderStatus.approved){
      url = "https://utsavlife.com/api/vendor-approve-order/${OrderId}" ;
    }
    else {
      url = "https://utsavlife.com/api/vendor-reject-order/${OrderId}" ;
    }
    Response response = await dio.get(url,
    options: Options(
        headers: {
        "Authorization":"Bearer ${auth.token}"
        }
    )
    );
    print(response.data);
    return "Order Status changed successfully";
  }
  catch(e){
    print(e);
    return Future.error(e);
  }
}