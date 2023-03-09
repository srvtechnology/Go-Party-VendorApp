import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:utsavlife/config.dart';

Future<String> login(String email,String password)async{
  Response response;
  try{
      response = await Dio().post("${APIConfig.baseUrl}/api/vendor/login",data: FormData.fromMap({
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