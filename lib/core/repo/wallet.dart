import 'package:dio/dio.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/models/wallet.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';

Future<WalletModel> getWalletDetails(AuthProvider auth) async {
  try {
    Response response = await Dio().get(
        "${APIConfig.baseUrl}/api/manage-vendor/wallet",
        options: Options(headers: {"Authorization": "Bearer ${auth.token}"}));
    return WalletModel.fromJson(response.data);
  } catch (e) {
    if (e is DioError) {
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    rethrow;
  }
}

Future<List<Transaction>> getTransactionDetails(AuthProvider auth) async {
  try {
    Response response = await Dio().get(
        "${APIConfig.baseUrl}/api/manage-vendor/transactions",
        options: Options(headers: {"Authorization": "Bearer ${auth.token}"}));
    CustomLogger.debug(response.data);
    List<Transaction> data = [];
    for (var i in response.data["transactions"]) {
      data.add(Transaction.fromJson(i));
    }
    CustomLogger.debug(response.data);
    return data;
  } catch (e) {
    if (e is DioError) {
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    rethrow;
  }
}

Future<String?> withdrawAmountFromWallet(
    AuthProvider auth, String amount) async {
  try {
    Response response = await Dio().post(
        "${APIConfig.baseUrl}/api/manage-vendor/withdraw",
        options: Options(headers: {"Authorization": "Bearer ${auth.token}"}),
        data: {
          "wallet_amount": amount,
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> res = response.data;
      String status = res['status'];
      return status;
    } else {
      return null;

    }
  } catch (e) {
    if (e is DioError) {
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    return null;

  }
}
