import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/components/drawer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/otpProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';

import '../provider/RegisterProvider.dart';

Future<String> login(String email,String password)async{
  Response response;
  Dio dio = new Dio();

  try{
      response = await dio.post("${APIConfig.baseUrl}/api/vendor/login",data: FormData.fromMap({
        "email":email,
        "password":password,
        "user_type":"vendor",
      }));
      return response.data['result']['token'];
    }
    catch(e){
      return Future.error(e);
    }
}
Future<bool> signUpMain(Map data)async{
  Response response;
  try{
      response = await Dio().post("${APIConfig.baseUrl}/api/vendor/register",data:data);
      return true;
    }
    catch(e){
      if(e is DioError){
        CustomLogger.error(e.response?.data);
        return Future.error(ArgumentError(e.response!.data["error"].toString()));
      }
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
    return response.data["user"]["id"].toString();
  }
    catch(e){
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
    return Future.error(e);
  }
}
Future<bool> completeRegistration(RegisterProvider state,Map data)async{
  try{
  Response response = await Dio().post("${APIConfig.baseUrl}/api/vedor-register-part-registration",
  data: data,
    options: Options(headers: {
      "Authorization":"Bearer ${state.token}"
    })
  );
  CustomLogger.debug(response.data);
  return true;
  }
  catch(e){
    if(e is DioError){
      CustomLogger.error(e.response?.data);
    }
    return Future.error(e);
  }
}
Future<bool> completeRegistration2(RegisterProvider state,Map data)async{
  try{
    Response response = await Dio().post("${APIConfig.baseUrl}/api/vendor-register-part-three-registration",
        data: data,
        options: Options(headers: {
          "Authorization":"Bearer ${state.token}"
        })
    );
    CustomLogger.debug(response.data);
    return true;
  }
  catch(e){
    if(e is DioError){
      CustomLogger.error(e.response?.data);
    }
    return Future.error(e);
  }
}Future<bool> completeRegistrationIntermediate(RegisterProvider state,Map data)async{
  try{
    Response response = await Dio().post("${APIConfig.baseUrl}/api/vendor-register-part-two-registration",
        data: data,
        options: Options(headers: {
          "Authorization":"Bearer ${state.token}"
        })
    );
    CustomLogger.debug(response.data);
    return true;
  }
  catch(e){
    if(e is DioError){
      CustomLogger.error(e.response?.data);
    }
    return Future.error(e);
  }
}
Future<bool> completeRegistration3(RegisterProvider state,Map<String,dynamic> data)async{
  try{
    CustomLogger.debug(data);
    Response response = await Dio().post("${APIConfig.baseUrl}/api/vendor-register-part-four-registration",
        data: FormData.fromMap(data),
        options: Options(headers: {
          "Authorization":"Bearer ${state.token}"
        })
    );
    CustomLogger.debug(response.data);
    return true;
  }
  catch(e){
    if(e is DioError){
      CustomLogger.error(e.response?.data);
    }
    return Future.error(e);
  }
}