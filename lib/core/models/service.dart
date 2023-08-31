
class Driver{
  String? name,mobileNumber,kycType,kycNumber,licenseNumber,pinCode,houseNumber,area,landmark,city,state,image,dlImage;

  Driver({
    this.name,
    this.mobileNumber,
    this.kycType,
    this.kycNumber,
    this.licenseNumber,
    this.pinCode,
    this.houseNumber,
    this.area,
    this.landmark,
    this.city,
    this.state,
    this.image,
    this.dlImage
});
}

class ServiceModel {
  String id;
  String? categoryId,serviceId,address,serviceName,serviceDescription,materialDescription,company,priceBasis,price,discountedPrice,categoryName,categoryDescription,videoUrl;
  Driver driverDetails;
  List<String?> imageUrls;

  ServiceModel({
    required this.id,
    required this.driverDetails,
    required this.imageUrls,
    this.categoryId,
    this.serviceId,
    this.address,
    this.serviceName,
    this.serviceDescription,
    this.materialDescription,
    this.company,
    this.priceBasis,
    this.price,
    this.discountedPrice,
    this.categoryName,
    this.categoryDescription,
    this.videoUrl
});

  factory ServiceModel.fromJson(Map json){
    try {
      Map? service_details = json["service_details"]??null;
      Map? category_details = json["category_details"]??null;
      return ServiceModel(
        id: json["id"].toString(),
        serviceId: json["service_id"].toString(),
        address: json["address"]??null,
        serviceName:service_details!=null?service_details["service"]??null:null,
        serviceDescription: json["service_desc"]??null,
        materialDescription: json["material_desc"]??null,
        company: json["company_name"]??null,
        price: json["price"]!=null?json["price"].toString():"",
        priceBasis: service_details!=null?service_details["price_basis"]??null:null,
        discountedPrice: service_details!=null?service_details["discount_price"]:null,
        categoryName: category_details!=null?category_details["category_name"]:null,
        categoryDescription:category_details!=null?category_details["category_description"]:null,
        driverDetails: Driver(
          name: json["driver_name"],
          mobileNumber: json["driver_mobile_no"]??null,
          kycType: json["driver_kyc_type"]??null,
          kycNumber: json["driver_kyc_no"]??null,
          licenseNumber: json["driver_licence_no"]??null,
          pinCode: json["driver_pincode"]??null,
          houseNumber: json["driver_house_no"]??null,
          area: json["driver_area"]??null,
          landmark: json["driver_landmark"]??null,
          city: json["driver_city"]??null,
          state: json["driver_state"]??null,
          image: json["driver_image"]??null,
          dlImage: json["dl_image"]??null,
        ),
        imageUrls: [json["image"]??null,json["image2"]??null,json["image3"]??null,json["image4"]??null,json["image5"]??null],
        videoUrl: json["video"]??null
      );
    }
    catch(e){
      throw ArgumentError(e);
    }
    }
}

class ServiceOptionModel{
  String id,service,description,price,discountPrice;
  ServiceOptionModel({
    required this.id,
    required this.service,
    required this.description,
    required this.price,
    required this.discountPrice
});
  factory ServiceOptionModel.fromJson(Map json){
    return ServiceOptionModel(
        id: json["id"].toString(),
        service: json["service"],
        description: json["description"],
        price: json["price"].toString(),
        discountPrice: json["discount_price"]);
  }
}

class CategoryOptionModel{
  String id,name,description;
  CategoryOptionModel(
  {
    required this.id,
    required this.name,
    required this.description,
  }
  );

  factory CategoryOptionModel.fromJson(Map json){
    return CategoryOptionModel(id: json["id"].toString(), name: json["category_name"].toString(), description: json["category_description"]);
  }
}

class ServiceDropDownOptions{
  List<ServiceOptionModel> serviceOptions;

  ServiceDropDownOptions({
    required this.serviceOptions
});
}