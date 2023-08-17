import 'package:dio/dio.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';

Future<void> getWalletDetails(AuthProvider auth)async{
  try{
    CustomLogger.debug(auth.token);
    Response response = await Dio().get(
        "${APIConfig.baseUrl}/api/manage-vendor/wallet",
        options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
        )
    );
    CustomLogger.debug(response.data);
  }catch(e){
    if(e is DioError){
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    rethrow;
  }
}

Future<void> getTransactionDetails(AuthProvider auth)async{
  try{
    Response response = await Dio().get(
        "${APIConfig.baseUrl}/api/manage-vendor/transactions",
        options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
        )
    );
    CustomLogger.debug(response.data);
  }catch(e){
    if(e is DioError){
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    rethrow;
  }
}