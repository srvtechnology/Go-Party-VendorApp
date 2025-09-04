import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/auth.dart' as authRepo;
import 'package:utsavlife/core/utils/logger.dart';
import '../models/user.dart';

enum RegisterProgress {
  one,
  two,
  three,
  four,
  five,
  six,
  completed
}
// This class is not used
class RegisterProvider with ChangeNotifier {
  AuthProvider? auth;
  RegisterProgress _registerProgress=RegisterProgress.one;
  String? _token;
  late String _email,_password;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? get token => _token;
  RegisterProgress get registerProgress=>_registerProgress;
  RegisterProvider({this.auth}){
    getRegisterProgressFromStorage();
    getAuthToken();
  }
  void startloading(){
    _isLoading = true;
    notifyListeners();
  }
  void stoploading(){
    _isLoading = false;
    notifyListeners();
  }
  void getRegisterProgressFromStorage()async{
    final SharedPreferences instance = await SharedPreferences.getInstance();
    try{
    int? value = instance.getInt("progress");
    if(value!=null){
      switch(value){
        case 1:_registerProgress = RegisterProgress.one ;
          break;
        case 2:
          _registerProgress = RegisterProgress.two;
          getAuthToken();
          break;
        case 3:
          _registerProgress = RegisterProgress.three;
          getAuthToken();
          break;
        case 4:
          _registerProgress = RegisterProgress.four;
          getAuthToken();
          break;
          case 5:
          _registerProgress = RegisterProgress.five;
          getAuthToken();
          break;
          case 6:
          _registerProgress = RegisterProgress.six;
          getAuthToken();
          break;
      }
    }
    }catch(e){}
    notifyListeners();
  }
  Future<void> getAuthToken()async{
    startloading();
    try{
      if(auth!=null && auth?.token!=null){
        _token=auth?.token;
      }
      else{
        String? email = await getEmail();
        String? password = await getPassword();
        _token = await authRepo.login(email!, password!);
      }
      stoploading();
    }catch(e){
      CustomLogger.error(e);
      stoploading();
    }
  }
  void setEmailPassword({required String email,required String password})async{
    final SharedPreferences instance = await SharedPreferences.getInstance();
    instance.setString("regEmail", email);
    instance.setString("regPassword", password);
  }
  Future<String?> getEmail()async{
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getString("regEmail");
  }
  Future<String?> getPassword()async{
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getString("regPassword");
  }
  void setRegisterProgress(RegisterProgress progress)async{
    _registerProgress = progress;
    notifyListeners();
  }
  void clear()async{
    CustomLogger.debug("Deleting all data");
    final SharedPreferences instance = await SharedPreferences.getInstance();
    instance.clear();
  }
}

class RegisterCache{
    Map _data={};
    List<String> fields=[];
    Map get data => _data;
    RegisterCache({required this.fields}){
      getData(fields);
    }

    Future<void> getData(List<String> details)async{
      final SharedPreferences instance = await SharedPreferences.getInstance();
      for(String i in details){
        try{
         _data[i]=instance.getString(i)??"";
        }catch(e){
          _data[i]="";
        }
      }
    }
    void setData(Map details)async{
      final SharedPreferences instance = await SharedPreferences.getInstance();
      for(String i in details.keys){
        instance.setString(i, details[i]);
      }
    }
}