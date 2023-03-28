import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:utsavlife/core/models/user.dart';

import '../../config.dart';
import '../provider/AuthProvider.dart';

final logger = Logger();

Future<UserModel> get_UserData(String token)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  try{
    response = await dio.get("${APIConfig.baseUrl}/api/me",
        options: Options(
            headers: {
              "Authorization":"Bearer ${token}"
            }
        )
    );
    return UserModel.fromJson(response.data["data"]);
  }
  catch(e){
    print(e);
    return Future.error(e);
  }
}

Future<bool> edit_UserData(String token,Map updateFields)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  try{
    response = await dio.get("${APIConfig.baseUrl}/api/me",
        options: Options(
            headers: {
              "Authorization":"Bearer ${token}"
            }
        ),
      data: updateFields
    );
    return true;
  }
  catch(e){
    print(e);
    return false;
  }
}

