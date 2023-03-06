import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsavlife/core/repo/auth.dart' as authRepo;
enum AuthState {
  LoggedOut,
  Waiting,
  LoggedIn,
  Error
}
class AuthProvider with ChangeNotifier {
  AuthState _authState = AuthState.Waiting;
  String? _token=null;
  AuthState get authState => _authState;
  String? get token => _token ;
  late final SharedPreferences pref;
  void isLoggedIn(){
    if (_token==null){
      _authState = AuthState.LoggedOut ;
    }
    else{
      _authState = AuthState.LoggedIn;
    }
    notifyListeners();
  }
  void init()async{
    pref = await SharedPreferences.getInstance();
    String? tempToken =await getTokenFromStorage();
     if(tempToken==null){
       _authState = AuthState.LoggedOut;
     }
     else{
       _token = tempToken;
       _authState = AuthState.LoggedIn ;
     }
     notifyListeners();
  }
  void saveTokenToStorage(String tempToken){
      pref.setString("token", tempToken);
  }
  Future<String?> getTokenFromStorage()async{
      String? tempToken = await pref.getString("token");
      return tempToken;
  }
  void deleteTokenFromStorage(){
    pref.remove("token");
  }
  void login(String email,String password)async{
    _authState = AuthState.Waiting;
    notifyListeners();
    try {
      String tempToken = await authRepo.login(email, password);
      saveTokenToStorage(tempToken);
      _token = tempToken;
      _authState = AuthState.LoggedIn;
    }
    catch(e){
      _authState = AuthState.Error;
    }
    notifyListeners();
  }
  void logout(){
      _token = null;
      _authState = AuthState.LoggedOut;
      deleteTokenFromStorage();
      notifyListeners();
  }
}