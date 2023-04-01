import 'package:dio/dio.dart';
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

  void editProfile()async{
    bool status = await userRepo.edit_profile(_token!, {
      "name":_user!.name,
      "pan_card":_user!.panCardNumber,
      "kyc_type":_user!.kycType,
      "kyc_no":_user!.kycNumber,
      "pin_code":_user!.zip,
      "house_no":_user!.houseNumber,
      "area":_user!.area,
      "landmark":_user!.landmark,
      "city":_user!.city,
      "state":_user!.state,
    });
    if(status == true){
      getUser();
      notifyListeners();
    }
    else {
      
    }
  }

  void editOfficeDetails()async{
    bool status = await userRepo.edit_office_details(_token!, {
    "office_pincode":_user!.officeZip,
    "office_house_no":_user!.houseNumber,
    "office_area" :_user!.officeArea,
    "office_landmark" :_user!.officeLandmark,
    "office_city" :_user!.officeCity,
    "office_state":_user!.officeState,
    });
    if(status == true){
      getUser();
      notifyListeners();
    }
    else {

    }
  }

  void editDocument({String? panPath, String? kycPath, String? vendorPath, String? gstPath})async{
    Map<String,dynamic> data = {};
    if(panPath != null){
      data["img1"]= await MultipartFile.fromFile(panPath);
    }
    if (kycPath != null){
      data["img2"]= await MultipartFile.fromFile(kycPath);
    }
    if (vendorPath != null){
      data["img3"]=await MultipartFile.fromFile(vendorPath);
    }
    if (gstPath != null){
      data["img4"]=await MultipartFile.fromFile(gstPath);
    }
    bool status = await userRepo.edit_Document_details(_token!, data);
    if(status == true){
      getUser();
      notifyListeners();
    }
    else {

    }
  }
}