import 'package:flutter/cupertino.dart';

class PaymentStatusProvider extends ChangeNotifier{

  bool _isPaid = false;
  String _address="";
  String _shippingto="";


  String get address => _address;

  set address(String value) {
    _address = value;
  }

  bool get isPaid => _isPaid;

  set isPaid(bool value) {
    _isPaid = value;
    notifyListeners();
  }

  String get shippingto => _shippingto;

  set shippingto(String value) {
    _shippingto = value;
  }
}