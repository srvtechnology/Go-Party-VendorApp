import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';

import '../models/service.dart';

Future<List<ServiceModel>> getServiceList(AuthProvider auth)async{

  Response  response = await Dio().get("${APIConfig.baseUrl}/api/service-list-vendor",
        options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
        )
      );
      List<ServiceModel> services=[];
    try{
      CustomLogger.debug(response.data);
      for (var service in response.data["data"]){
        try{
          services.add(ServiceModel.fromJson(service));
        }catch(e){
          CustomLogger.error(e);
        }
      }
      return services;
    }
    catch(e){
      CustomLogger.error(e);
      return Future.error(e);
    }
}

Future createService(AuthProvider auth,Map<String,dynamic> serviceData)async{
  try{
    Response  response = await Dio().post("${APIConfig.baseUrl}/api/service-insert",
      options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
      ),
        data: FormData.fromMap(serviceData),
  );
    CustomLogger.debug(response.data);
    return Future.value(true);
  }
  catch(e){
    if(e is DioError){
      CustomLogger.error(e.response?.data);
    }
    throw e;
  }
}

Future<bool> deleteService(AuthProvider auth,String serviceId)async{
  try{
    Response  response = await Dio().get("${APIConfig.baseUrl}/api/service-delete/$serviceId",
      options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
      ),
    );
    return true;
  }
  catch(e){
    if(e is DioError){
      CustomLogger.error(e.response?.data);
    }
    return Future.error(e);
  }
}

Future<bool> updateService(AuthProvider auth,String id,Map<String,dynamic> data)async{
  try{
    Response  response = await Dio().post("${APIConfig.baseUrl}/api/service-update",
      options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
      ),
      data: FormData.fromMap(data)
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

Future<ServiceDropDownOptions> getServiceOptions(dynamic auth)async{
  try{
    CustomLogger.debug("getting service options");
    Response  response = await Dio().get("${APIConfig.baseUrl}/api/service-list-add-view",
      options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
      ),
    );
    List<ServiceOptionModel> serviceOptions=[];
    CustomLogger.debug(response.data);
    for(var i in response.data["services"]){
      try{
        serviceOptions.add(ServiceOptionModel.fromJson(i));
      }catch(e){}
    }
    return ServiceDropDownOptions(serviceOptions: serviceOptions);
  }
  catch(e){
    if(e is DioError){
      CustomLogger.error(e.response?.data);
      auth.getAuthToken();
    }
    return Future.error(e);
  }
}


