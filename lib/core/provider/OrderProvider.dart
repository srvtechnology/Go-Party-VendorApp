import 'package:flutter/material.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/otpProvider.dart';
import 'package:utsavlife/core/repo/order.dart';

class UpcomingOrderProvider with ChangeNotifier{
  List<OrderModel> _orders = [];
  bool _isLoading=false;
  AuthProvider auth;
  bool get isLoading=>_isLoading;
  List<OrderModel> get orders => _orders ;
  UpcomingOrderProvider({required this.auth}){
    this.load_upcoming_orders();
  }
  void startLoading(){
    _isLoading=true;
    notifyListeners();
  }
  void stopLoading(){
    _isLoading = false;
    notifyListeners();
  }
  void load_upcoming_orders()async{
    startLoading();
    _orders = await get_upcoming_order_list(auth);
    stopLoading();
  }

}
class HistoryOrderProvider with ChangeNotifier{
  List<OrderModel> _orders = [];
  bool _isLoading=false;
  AuthProvider auth;
  bool get isLoading=>_isLoading;
  List<OrderModel> get orders => _orders ;
  HistoryOrderProvider({required this.auth}){
    this.load_history_orders();
  }
  void startLoading(){
    _isLoading=true;
    notifyListeners();
  }
  void stopLoading(){
    _isLoading = false;
    notifyListeners();
  }
  void load_history_orders()async{
    startLoading();
    _orders = await get_history_order_list(auth);
    stopLoading();
  }

}

class SingleOrderProvider with ChangeNotifier{
  OrderModel? _order;
  String id;
  String? successMessage;
  AuthProvider auth;
  bool _isLoading=true;
  bool get isLoading=>_isLoading;
  OrderModel? get order => _order ;

  SingleOrderProvider({required this.id,required this.auth}){
    this.get_order_by_id(auth, id);
  }
  void startLoading(){
    _isLoading=true;
    notifyListeners();
  }
  void stopLoading(){
    _isLoading = false;
    notifyListeners();
  }
  void get_order_by_id(AuthProvider auth,String id)async{
    startLoading();
    _order = await get_orderById(auth, id);
    stopLoading();
  }
  Future<void> change_status(VendorOrderStatus status,String reason)async{
    startLoading();
    try{
      successMessage = await ChangeOrderStatus(auth, status, _order!.id,reason);
      _order?.vendorOrderStatus = status ;
    }
    catch(e){
      logger.e(e.toString());
    }
    stopLoading();
  }
}

class ReasonProvider with ChangeNotifier {
  late List<String>? _reasons;
  AuthProvider auth;
  List<String>? get reasons => _reasons;
  ReasonProvider({required this.auth}){
    getReason();
  }
  void getReason()async{
    _reasons = await getRejectReasons(auth);
    notifyListeners();
  }
}
