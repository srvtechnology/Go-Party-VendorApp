// To parse this JSON data, do
//
//     final generateOrderValue = generateOrderValueFromMap(jsonString);

import 'dart:convert';

GenerateOrderValue generateOrderValueFromMap(String str) =>
    GenerateOrderValue.fromMap(json.decode(str));

String generateOrderValueToMap(GenerateOrderValue data) =>
    json.encode(data.toMap());

class GenerateOrderValue {
  int? orderId;
  String? accessCode;
  String? redirectUrl;
  String? cancelUrl;
  String? encVal;

  GenerateOrderValue({
    this.orderId,
    this.accessCode,
    this.redirectUrl,
    this.cancelUrl,
    this.encVal,
  });

  GenerateOrderValue copyWith({
    int? orderId,
    String? accessCode,
    String? redirectUrl,
    String? cancelUrl,
    String? encVal,
  }) =>
      GenerateOrderValue(
        orderId: orderId ?? this.orderId,
        accessCode: accessCode ?? this.accessCode,
        redirectUrl: redirectUrl ?? this.redirectUrl,
        cancelUrl: cancelUrl ?? this.cancelUrl,
        encVal: encVal ?? this.encVal,
      );

  factory GenerateOrderValue.fromMap(Map<String, dynamic> json) =>
      GenerateOrderValue(
        orderId: json["order_id"],
        accessCode: json["access_code"],
        redirectUrl: json["redirect_url"],
        cancelUrl: json["cancel_url"],
        encVal: json["enc_val"],
      );

  Map<String, dynamic> toMap() => {
        "order_id": orderId,
        "access_code": accessCode,
        "redirect_url": redirectUrl,
        "cancel_url": cancelUrl,
        "enc_val": encVal,
      };
}
