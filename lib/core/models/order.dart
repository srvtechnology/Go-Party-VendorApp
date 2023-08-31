
import 'package:utsavlife/core/utils/logger.dart';

class Category{

}

class Customer{

}
enum VendorOrderStatus{
  upcoming,
  pending,
  rejected,
  approved,
}
class CustomerDetailsModel {
  String name;
  String? email,phoneNumber;
  CustomerDetailsModel({
   required this.name,
   this.email,
   this.phoneNumber
});
  factory CustomerDetailsModel.fromJson(Map json){
    return CustomerDetailsModel(name: json["name"], email: json["email"],phoneNumber: json["mobile"]);
  }
}

enum OrderPaymentStatus {
  partial,
  completed
}
class OrderModel {
  String id;
  String address;
  String latitude;
  String longitude;
  String date;
  String amount;
  String? category;
  String? service_name;
  String? end_date;
  String? timing;
  String days;
  CustomerDetailsModel? customer;
  OrderPaymentStatus paymentStatus;
  VendorOrderStatus vendorOrderStatus ;
  OrderModel(
      {
        required this.id,
        required this.address,
        required this.latitude,
        required this.longitude,
        required this.date,
        required this.amount,
        required this.vendorOrderStatus,
        required this.days,
        required this.paymentStatus,
        this.customer,
        this.category,
        this.end_date,
        this.service_name,
        this.timing,
      }
      );

  factory OrderModel.fromJson(Map json){
    VendorOrderStatus tempStatus = VendorOrderStatus.pending;
    String tempTiming="Morning";
    String tempServiceName = "";
    String tempCategoryName = "";
    try{
      switch(json["vandor_order_status"]){
        case "AP":tempStatus = VendorOrderStatus.approved ;
                  break;
        case "RJ":tempStatus = VendorOrderStatus.rejected ;
      }
    }catch(e){}
    try{
      tempCategoryName=json["category_details"]["category_name"];
    }catch(e){

    }
    try{
      tempServiceName=json["service_details"]["service"];
    }catch(e){

    }
    try{
      switch(json["data"]["time"]){
        case "M":tempTiming = "Morning" ;
        break;
        case "A":tempTiming = "Afternoon" ;
        break;
        case "E": tempTiming = "Evening";
        break;
        case "N": tempTiming = "Night";
        break;
      }
    }catch(e){}
    return OrderModel(
        id: json["id"].toString(),
        paymentStatus: json["paid_status"]=="partial"?OrderPaymentStatus.partial:OrderPaymentStatus.completed,
        address: json["event_address"].toString(),
        latitude: json["lat"].toString(),
        longitude: json["long"].toString(),
        date:json["event_date"].toString(),
        amount: json["total_price"].toString(),
        vendorOrderStatus: tempStatus,
        days: json["days"].toString(),
        customer: CustomerDetailsModel.fromJson(json["customer_details"]),
        timing: tempTiming,
        end_date:json["event_end_date"].toString(),
      service_name: tempServiceName,
      category: tempCategoryName,
    );
  }
}