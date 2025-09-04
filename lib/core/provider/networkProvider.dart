import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:utsavlife/core/utils/logger.dart';

class NetworkProvider with ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  NetworkProvider() {
    CustomLogger.debug("Init Connection");
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      CustomLogger.debug(results);
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        _isOnline = true;
      } else {
        _isOnline = false;
      }
      notifyListeners();
    });
  }
}
