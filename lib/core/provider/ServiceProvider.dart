import 'package:flutter/cupertino.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/service.dart' as serviceRepo;
import '../models/service.dart';

class ServiceListProvider with ChangeNotifier {
    List<serviceModel>? services;
    AuthProvider auth;
    bool isLoading = false;

    void startLoading(){
      isLoading = true;
      notifyListeners();
    }
    void stopLoading(){
      isLoading = false;
      notifyListeners();
    }

    ServiceListProvider({required this.auth}){
      getList();
    }

    Future<void> getList()async{
      startLoading();
      try {
        services = await serviceRepo.getServiceList(auth);
      }
      catch(e){
        stopLoading();
        throw ArgumentError("Something wrong in fetching list");
      }
      stopLoading();
      }

}


class DropDownOptionProvider with ChangeNotifier {
  ServiceDropDownOptions? options;
  bool isLoading = false;
  dynamic auth;
  void startLoading(){
    isLoading = true;
    notifyListeners();
  }
  void stopLoading(){
    isLoading = false;
    notifyListeners();
  }
  DropDownOptionProvider({required this.auth}){
    getOptions();
  }
  Future<void> getOptions()async{
    startLoading();
    options=await serviceRepo.getServiceOptions(auth);
    stopLoading();
  }

}