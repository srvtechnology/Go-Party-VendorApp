import 'package:flutter/material.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/order.dart';

class OrderProvider with ChangeNotifier{
  List<OrderModel> _orders = [];
  bool _isLoading=false;
  AuthProvider auth;
  bool get isLoading=>_isLoading;
  List<OrderModel> get orders => _orders ;
  OrderProvider({required this.auth}){
    this.load_upcoming_orders(auth);
  }
  void load_upcoming_orders(AuthProvider auth)async{
    _isLoading=true;
    notifyListeners();
    _orders = await get_upcoming_order_list(auth);
    _isLoading = false;
    notifyListeners();
  }
}
class SingleOrderProvider with ChangeNotifier{
  OrderModel? _order;
  String id;
  AuthProvider auth;
  bool _isLoading=true;
  bool get isLoading=>_isLoading;
  OrderModel? get order => _order ;

  SingleOrderProvider({required this.id,required this.auth}){
    this.get_order_by_id(auth, id);
  }

  void get_order_by_id(AuthProvider auth,String id)async{
    _isLoading=true;
    notifyListeners();
    _order = await get_orderById(auth, id);
    _isLoading = false;
    notifyListeners();
  }
}
