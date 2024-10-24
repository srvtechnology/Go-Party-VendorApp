import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class PaymentRepo {
  static Future<http.Response> post(String url,
      {Map<String, dynamic>? data, head}) async {
    log("POST url: $url");
    log("POST data: ${jsonEncode(data)}");
    return await http
        .post(Uri.parse(url),
            body: jsonEncode(data),
            headers: head ??
                {
                  "Content-Type": "application/json",
                  'Accept': 'application/json',
                })
        .then((value) => value);
  }
}
