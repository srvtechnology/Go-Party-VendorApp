import 'package:dio/dio.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/models/wallet.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';

Future<WalletModel> getWalletDetails(AuthProvider auth)async{
  try{
    Response response = await Dio().get(
        "${APIConfig.baseUrl}/api/manage-vendor/wallet",
        options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
        )
    );
    return WalletModel.fromJson(response.data);
  }catch(e){
    if(e is DioError){
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    rethrow;
  }
}

Future<List<Transaction>> getTransactionDetails(AuthProvider auth)async{
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
    List<Transaction> data=[];
    for (var i in response.data["transactions"]){
      data.add(Transaction.fromJson(i));
    }
    CustomLogger.debug(response.data);
    return data;
  }catch(e){
    if(e is DioError){
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    rethrow;
  }
}

Future withdrawAmountFromWallet(AuthProvider auth,String amount)async{
  try{
    Response response = await Dio().post(
        "${APIConfig.baseUrl}/api/manage-vendor/withdraw",
        data: {
          "wallet_amount":amount,
    }
    );
  }catch(e){
    if(e is DioError){
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
  }
}