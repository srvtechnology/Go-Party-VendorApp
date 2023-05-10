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

class serviceModel {
  String id;
  String? categoryId,serviceId,address,serviceName,serviceDescription,materialDescription,company,priceBasis,price,discountedPrice,categoryName,categoryDescription,videoUrl;
  Driver driverDetails;
  List<String?> imageUrls;

  serviceModel({
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

  factory serviceModel.fromJson(Map json){
    try {
      Map service_details = json["service_details"];
      Map category_details = json["category_details"];
      return serviceModel(
        id: json["id"].toString(),
        categoryId: json["category"],
        serviceId: json["service_id"].toString(),
        address: json["address"],
        serviceName:service_details["service"],
        serviceDescription: json["service_desc"],
        materialDescription: json["material_desc"],
        company: json["company_name"],
        price: json["price"].toString(),
        priceBasis: service_details["price_basis"],
        discountedPrice: service_details["discount_price"],
        categoryName: category_details["category_name"],
        categoryDescription: category_details["category_description"],
        driverDetails: Driver(
          name: json["driver_name"],
          mobileNumber: json["driver_mobile_no"],
          kycType: json["driver_kyc_type"],
          kycNumber: json["driver_kyc_no"],
          licenseNumber: json["driver_licence_no"],
          pinCode: json["driver_pincode"],
          houseNumber: json["driver_house_no"],
          area: json["driver_area"],
          landmark: json["driver_landmark"],
          city: json["driver_city"],
          state: json["driver_state"],
          image: json["driver_image"],
          dlImage: json["dl_image"],
        ),
        imageUrls: [json["image"]??null,json["image2"]??null,json["image3"]??null,json["image4"]??null,json["image5"]??null],
        videoUrl: json["video"]
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
  List<CategoryOptionModel> categoryOptions;
  List<ServiceOptionModel> serviceOptions;

  ServiceDropDownOptions({
    required this.categoryOptions,
    required this.serviceOptions
});
}