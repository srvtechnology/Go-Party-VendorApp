import 'package:flutter/cupertino.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/wallet.dart';

class WalletProvider with ChangeNotifier{
  bool _isLoading=true;
  bool get isLoading=>_isLoading;

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

  void getDetails(AuthProvider auth){
    startLoading();
    getWalletDetails(auth);
    stopLoading();
  }
}