import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/repo/auth.dart' as authRepo;
import 'package:utsavlife/core/repo/user.dart' as userRepo;
enum AuthState {
  LoggedOut,
  Waiting,
  LoggedIn,
  Error
}
class AuthProvider with ChangeNotifier {
  AuthState _authState = AuthState.Waiting;
  String? _token=null;
  UserModel? _user;
  late final SharedPreferences pref;
  String? get token => _token ;
  AuthState get authState => _authState;
  UserModel? get user => _user ;
  void isLoggedIn(){
    if (_token==null){
      _authState = AuthState.LoggedOut ;
    }
    else{
      _authState = AuthState.LoggedIn;
    }
    notifyListeners();
  }
  AuthProvider(){
    init();
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
       print("Logged in");
       getUser();
     }
     notifyListeners();
  }
  void getUser()async{
    print("Getting user data");
    _user = await userRepo.get_UserData(_token!); // from repo
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
      getUser();
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

  void editUser(Map fields)async{
    bool status = await userRepo.edit_UserData(_token!, fields);
    if(status == true){
      getUser();
    }
    else {
      
    }
  }
}