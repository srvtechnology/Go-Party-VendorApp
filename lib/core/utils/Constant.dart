import 'package:utsavlife/config.dart';

class Constant {
  static String label_terms_condition = "Terms and Conditions";
  static String label_privacy_policy = "Privacy Policy";

  static String link_terms_condition = "${APIConfig.baseUrl}/terms-condition";
  static String link_privacy_policy = '${APIConfig.baseUrl}/privacy-policy';

  static final String passbook_prefix_url =
      "${APIConfig.baseUrl}/storage/app/public/vandor/checkbookOrPassbookImage/";
}
