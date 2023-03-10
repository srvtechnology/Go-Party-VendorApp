import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:utsavlife/config.dart';

Future<String> login(String email,String password)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  try{
      response = await dio.post("${APIConfig.baseUrl}/api/vendor/login",data: FormData.fromMap({
        "email":email,
        "password":password,
        "user_type":"vendor",
      }));
      return response.data['result']['token'];
    }
    catch(e){
      print(e);
      return Future.error(e);
    }
}