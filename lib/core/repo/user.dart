import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:utsavlife/core/models/user.dart';
import '../../config.dart';

Future<UserModel> get_UserData(String token)async{
  Response response;
  try{
    response = await Dio().get("${APIConfig.baseUrl}/api/me",
        options: Options(
            headers: {
              "Authorization":"Bearer ${token}"
            }
        )
    );
    return UserModel.fromJson(response.data);
  }
  catch(e){
    print(e);
    return Future.error(e);
  }
}

Future<bool> edit_profile(String token,Map updateFields)async{
  Response response;
  Dio dio = new Dio();
  try{
    response = await dio.post("${APIConfig.baseUrl}/api/vendor-profile-update",
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


Future<bool> edit_office_details(String token,Map updateFields)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  try{
    response = await dio.post("${APIConfig.baseUrl}/api/vendor-office-address-update",
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

Future<bool> edit_Document_details(String token,Map<String,dynamic> updateFields)async{
  Response response;
  Dio dio = new Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  try{
    response = await dio.post("${APIConfig.baseUrl}/api/vendor-all-images-update",
        options: Options(
            headers: {
              "Authorization":"Bearer ${token}"
            }
        ),
        data: FormData.fromMap(updateFields)
    );
    Logger().d(response.data);
    return true;
  }
  catch(e){
    print(e);
    return false;
  }
}

