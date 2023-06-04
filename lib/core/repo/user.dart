import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/utils/logger.dart';
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
    CustomLogger.debug(updateFields);
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
    if(e is DioError)
      {
        CustomLogger.error(e.response?.data);
      }
    return false;
  }
}


Future<bool> edit_office_details(String token,Map updateFields)async{
  try{
    Response response = await Dio().post("${APIConfig.baseUrl}/api/vendor-office-address-update",
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
    if(e is DioError){
      CustomLogger.error(e.response?.data);
    }
    CustomLogger.error(e);
    return false;
  }
}

Future<bool> edit_Document_details(String token,Map<String,dynamic> updateFields)async{
  Response response;
  try{
    response = await Dio().post("${APIConfig.baseUrl}/api/vendor-all-images-update",
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
    CustomLogger.error(e);
    if (e is DioError){
      CustomLogger.error(e.response?.data);
    }
    return false;
  }
}

