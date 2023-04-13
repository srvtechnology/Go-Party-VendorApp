import 'package:dio/dio.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';

import '../models/service.dart';

Future<List<serviceModel>> getServiceList(AuthProvider auth)async{

  Response  response = await Dio().get("${APIConfig.baseUrl}/api/service-list-vendor",
        options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
        )
      );
      List<serviceModel> services=[];
    try{
      for (var service in response.data["data"]){
        services.add(serviceModel.fromJson(service));
      }
      return services;
    }
    catch(e){
      CustomLogger.error(e);
      return Future.error(e);
    }
}