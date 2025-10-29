import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/repo/auth.dart' as authRepo;
import 'package:utsavlife/core/repo/user.dart' as userRepo;
import 'package:utsavlife/core/utils/logger.dart';
import 'RegisterProvider.dart';

enum AuthState { LoggedOut, Waiting, LoggedIn, Error }

class AuthProvider with ChangeNotifier {
  AuthState _authState = AuthState.Waiting;
  String? _token;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _user;
  late final SharedPreferences pref;

  String? get token => _token;
  AuthState get authState => _authState;
  UserModel? get user => _user;

  AuthProvider() {
    init();
  }

  // ---------------- Core Auth Logic ----------------

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void isLoggedIn() {
    if (_token == null) {
      _authState = AuthState.LoggedOut;
    } else {
      _authState = AuthState.LoggedIn;
    }
    notifyListeners();
  }

  void init() async {
    startLoading();
    pref = await SharedPreferences.getInstance();
    String? tempToken = await getTokenFromStorage();
    if (tempToken == null) {
      _authState = AuthState.LoggedOut;
    } else {
      _token = tempToken;
      await getUser();
      _authState = AuthState.LoggedIn;
    }
    stopLoading();
  }

  Future<void> getUser() async {
    try {
      _user = await userRepo.get_UserData(_token!);
    } catch (e) {
      CustomLogger.error("Failed to fetch user: $e");
    }
  }

  Future<void> getUserbytoken(String token) async {
    try {
      _user = await userRepo.get_UserData(token);
    } catch (e) {
      CustomLogger.error("Failed to fetch user by token: $e");
    }
  }

  // ---------------- Storage Helpers ----------------

  void saveTokenToStorage(String tempToken) {
    pref.setString("token", tempToken);
  }

  void saveEmailPasswordToStorage(String email, String password) {
    pref.setString("email", email);
    pref.setString("password", password);
  }

  Future<String?> getTokenFromStorage() async => pref.getString("token");
  Future<String?> getEmailFromStorage() async => pref.getString("email");
  Future<String?> getPasswordFromStorage() async => pref.getString("password");

  void deleteTokenFromStorage() {
    pref.remove("token");
    pref.remove("email");
    pref.remove("password");
  }

  void deleteAllFromStorage() {
    pref.clear();
  }

  void reLogin() async {
    String? email = await getEmailFromStorage();
    String? password = await getPasswordFromStorage();
    if (email != null && password != null) login(email, password);
  }

  Future<void> login(String email, String password) async {
    _authState = AuthState.Waiting;
    notifyListeners();
    try {
      String tempToken = await authRepo.login(email, password);
      saveTokenToStorage(tempToken);
      saveEmailPasswordToStorage(email, password);
      _token = tempToken;
      await getUser();
      _authState = AuthState.LoggedIn;
    } catch (e) {
      _authState = AuthState.Error;
    }
    notifyListeners();
  }

  void logout() {
    _token = null;
    _authState = AuthState.LoggedOut;
    _user = null;
    notifyListeners();
    deleteTokenFromStorage();
    deleteAllFromStorage();
  }

  // ---------------- Profile & Document Updates ----------------

  void editProfile() async {
    bool status = await userRepo.edit_profile(_token!, {
      "name": _user!.name,
      "pan_card": _user!.panCardNumber,
      "kyc_type": _user!.kycType,
      "kyc_no": _user!.kycNumber,
      "gst_no": _user!.gstNumber,
      "pin_code": _user!.zip,
      "house_no": _user!.houseNumber,
      "area": _user!.area,
      "landmark": _user!.landmark,
      "city": _user!.city,
      "state": _user!.state,
      "country": _user!.country?.id,
      "mobile": _user!.mobileno
    });
    if (status == true) {
      await getUser();
      notifyListeners();
    }
  }

  /// ✅ FIXED: Removed getUser() call before updating progress
  void setRegisterProgress(RegisterProgress progress) {
    if (_user == null) return;
    _user!.progress = progress;
    notifyListeners();
  }

  void editOfficeDetails() async {
    Map<String, dynamic> data = {
      "office_mobile": _user!.officePhone,
      "office_pincode": _user!.officeZip,
      "office_house_no": _user!.officeNumber,
      "office_area": _user!.officeArea,
      "office_landmark": _user!.officeLandmark,
      "office_city": _user!.officeCity,
      "office_state": _user!.officeState,
      "gst_no": _user!.gstNumber,
      "office_country": _user!.officeCountry!.id
    };
    bool status = await userRepo.edit_office_details(_token!, data);
    if (status == true) {
      await getUser();
      notifyListeners();
    }
  }

  void clear()async{
    CustomLogger.debug("Deleting all data");
    final SharedPreferences instance = await SharedPreferences.getInstance();
    instance.clear();
  }

  void editDocument({
    String? panPath,
    String? kycPath,
    String? vendorPath,
    String? gstPath,
  }) async {
    Map<String, dynamic> data = {};
    if (panPath != null) data["img1"] = await MultipartFile.fromFile(panPath);
    if (kycPath != null) data["img2"] = await MultipartFile.fromFile(kycPath);
    if (vendorPath != null) data["img3"] = await MultipartFile.fromFile(vendorPath);
    if (gstPath != null) data["img4"] = await MultipartFile.fromFile(gstPath);

    bool status = await userRepo.edit_Document_details(_token!, data);
    if (status == true) {
      await getUser();
      notifyListeners();
    }
  }

  Future<Response?> submitOtp(AuthProvider state, String userid, String otp) async {
    try {
      Response? response = await authRepo.submitVendorOtp(state, userid, otp);

      if (response != null) {
        final data = response.data;

        if (data["success"] == true || data["result"]?["code"] == "200") {
          saveTokenToStorage(data["token"]);
          _token=data["token"];
          await getUserbytoken(data["token"]);
          notifyListeners();
        } else {
          final message = data["message"] ?? "OTP verification failed";
          CustomLogger.error("OTP Error: $message");
        }

        return response;
      }
      return null;
    } catch (e) {
      CustomLogger.error("OTP submission failed: $e");
      return null;
    }
  }

  Future<void> editProfileImage({required String profilePath}) async {
    Map<String, dynamic> data = {
      "img3": await MultipartFile.fromFile(profilePath)
    };
    bool status = await userRepo.edit_Document_details(_token!, data);
    if (status == true) {
      await getUser();
      notifyListeners();
    }
  }

  Future<Response?> resendOtp(String userId) async {
    try {
      var response = await authRepo.resendVendorOtp(userId);
      if (response != null) {
        CustomLogger.debug("OTP resent successfully.");
        // You can optionally refresh something if needed
      }
      return response;
    } catch (e) {
      CustomLogger.error("Resend OTP failed: $e");
      return null;
    }
  }
}
