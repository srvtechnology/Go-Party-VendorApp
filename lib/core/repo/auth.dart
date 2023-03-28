import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/provider/otpProvider.dart';

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
}Future<String> GetOtp(String email)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  try {
    response = await dio.post("${APIConfig.baseUrl}/api/vendor/forget-password",
        data: FormData.fromMap({
          "email": email,
        }));
    Logger().d(response.data);
    return response.data["user"]["id"].toString();
  }
    catch(e){
      print(e);
      return Future.error(e);
    }
}
Future<String> resetPassword(String userId,String password,String otp)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  try {
    response = await dio.post("${APIConfig.baseUrl}/api/vendor/reset-password",
        data: FormData.fromMap({
          "otp": otp,
          "user_id":userId,
          "password":password
        }));
    logger.d(response.data);
    return response.data["message"];
  }
  catch(e){
    print(e);
    return Future.error(e);
  }
}