// To parse this JSON data, do
//
//     final orderRes = orderResFromJson(jsonString);

import 'dart:convert';

OrderRes orderResFromJson(String str) => OrderRes.fromJson(json.decode(str));

String orderResToJson(OrderRes data) => json.encode(data.toJson());

class OrderRes {
  bool? status;
  int? orderId;
  LPayObject? partialPayObject;
  LPayObject? fullPayObject;
  String? messgae;

  OrderRes({
    this.status,
    this.orderId,
    this.partialPayObject,
    this.fullPayObject,
    this.messgae,
  });

  OrderRes copyWith({
    bool? status,
    int? orderId,
    LPayObject? partialPayObject,
    LPayObject? fullPayObject,
    String? messgae,
  }) =>
      OrderRes(
        status: status ?? this.status,
        orderId: orderId ?? this.orderId,
        partialPayObject: partialPayObject ?? this.partialPayObject,
        fullPayObject: fullPayObject ?? this.fullPayObject,
        messgae: messgae ?? this.messgae,
      );

  factory OrderRes.fromJson(Map<String, dynamic> json) => OrderRes(
        status: json["status"],
        orderId: json["order_id"],
        partialPayObject: json["partialPayObject"] == null
            ? null
            : LPayObject.fromJson(json["partialPayObject"]),
        fullPayObject: json["fullPayObject"] == null
            ? null
            : LPayObject.fromJson(json["fullPayObject"]),
        messgae: json["messgae"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "order_id": orderId,
        "partialPayObject": partialPayObject?.toJson(),
        "fullPayObject": fullPayObject?.toJson(),
        "messgae": messgae,
      };
}

class LPayObject {
  int? orderId;
  String? accessCode;
  String? redirectUrl;
  String? cancelUrl;
  String? encVal;

  LPayObject({
    this.orderId,
    this.accessCode,
    this.redirectUrl,
    this.cancelUrl,
    this.encVal,
  });

  LPayObject copyWith({
    int? orderId,
    String? accessCode,
    String? redirectUrl,
    String? cancelUrl,
    String? encVal,
  }) =>
      LPayObject(
        orderId: orderId ?? this.orderId,
        accessCode: accessCode ?? this.accessCode,
        redirectUrl: redirectUrl ?? this.redirectUrl,
        cancelUrl: cancelUrl ?? this.cancelUrl,
        encVal: encVal ?? this.encVal,
      );

  factory LPayObject.fromJson(Map<String, dynamic> json) => LPayObject(
        orderId: json["order_id"],
        accessCode: json["access_code"],
        redirectUrl: json["redirect_url"],
        cancelUrl: json["cancel_url"],
        encVal: json["enc_val"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "access_code": accessCode,
        "redirect_url": redirectUrl,
        "cancel_url": cancelUrl,
        "enc_val": encVal,
      };
}
