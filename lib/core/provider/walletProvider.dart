import 'package:flutter/cupertino.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/wallet.dart';

import '../models/wallet.dart';

class WalletProvider with ChangeNotifier{
  bool _isLoading=true;
  bool get isLoading=>_isLoading;
  late WalletModel _walletData;
  WalletModel get walletData=>_walletData;
  late List<Transaction> _transactionData;
  List<Transaction> get transactionData => _transactionData;

  WalletProvider(AuthProvider auth){
    getDetails(auth);
  }
  void startLoading(){
    _isLoading=true;
    notifyListeners();
  }
  void stopLoading(){
    _isLoading = false;
    notifyListeners();
  }

  void getDetails(AuthProvider auth)async{
    startLoading();
    _walletData=await getWalletDetails(auth);
    _transactionData= await getTransactionDetails(auth);
    stopLoading();
  }
}