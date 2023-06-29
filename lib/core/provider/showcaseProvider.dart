import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowCaseProvider with ChangeNotifier{
  bool _show = true;
  SharedPreferences? _pref;
  bool get show => _show;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void startLoading(){
    _isLoading = true;
    notifyListeners();
  }
  void stopLoading(){
    _isLoading = false;
    notifyListeners();
  }

  ShowCaseProvider(){
    initShow();
  }
  void initShow()async{
    startLoading();
    _pref = await SharedPreferences.getInstance();
    await getState();
    stopLoading();
  }
  Future<void> getState()async{
      _show = _pref!.getBool("showcase")??true;
  }
  Future<void> setState()async{
    _pref!.setBool("showcase", false);
    notifyListeners();
  }

}