
class Category{

}

class Customer{

}
enum VendorOrderStatus {
  upcoming,
  pending,
  rejected,
  approved,
}
class OrderModel {
  String id;
  String address;
  String latitude;
  String longitude;
  String date;
  VendorOrderStatus vendorOrderStatus ;
  OrderModel(
      {
        required this.id,
        required this.address,
        required this.latitude,
        required this.longitude,
        required this.date,
        required this.vendorOrderStatus
      }
      );

  factory OrderModel.fromJson(Map json){

    return OrderModel(
        id: json["data"]["id"].toString(),
        address: json["data"]["address"],
        latitude: json["data"]["lat"],
        longitude: json["data"]["long"],
        date:json["data"]["event_date"],
        vendorOrderStatus: VendorOrderStatus.pending
    );
  }
}