import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:utsavlife/core/repo/auth.dart' as authRepo;
final logger = Logger();
class OtpProvider extends ChangeNotifier {
  String? _user_id ;
  String? _password ;
  String? _otp;
  String? _errorMessage;
  bool _passwordChanged = false;
  bool _isLoading = false;
  String? get errorMessage => _errorMessage ;
  String? get userId => _user_id ;
  bool get passwordChanged => _passwordChanged;
  bool get isLoading => _isLoading;
  String? get otp => _otp;
  set otp(String? t){
    _otp = t ;
    notifyListeners();
  }
  void _startLoading(){
    _isLoading = true;
    notifyListeners();
  }
  void _stopLoading(){
    _isLoading = false;
    notifyListeners();
  }
  void get_otp(String email)async{
   try{
     _startLoading();
     _user_id = await authRepo.GetOtp(email);
     logger.d(_user_id);
     _stopLoading();
   }
   catch(e){
     _errorMessage = e.toString();
   }
  }
  Future<void> setPassword(String password)async{
    _startLoading();
    try{
      await authRepo.resetPassword(_user_id!, password, _otp!);
      _passwordChanged = true;
    }catch(e){
      logger.e(e.toString());
    }
    _stopLoading();
  }
}