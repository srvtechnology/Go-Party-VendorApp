class BankDetails{
  String id,accountNumber,bankName,ifscNumber,holderName,branchName,accountType;
  BankDetails({
    required this.id,
    required this.accountNumber,
    required this.bankName,
    required this.ifscNumber,
    required this.holderName,
    required this.branchName,
    required this.accountType
  });

  factory BankDetails.fromJson(Map json){
    return BankDetails(
        id: json["id"].toString(),
        accountNumber: json["acc_no"],
        bankName: json["bank_name"],
        ifscNumber: json["ifsc_no"],
        holderName: json["holder_name"],
        branchName: json["branch_name"],
        accountType: json["acc_type"]);
  }
}
class UserModel {
  String id,name,email;
  // personal details
  String? mobileno,country,landmark,state,city,zip,area,panCardNumber,callingNumber,kycNumber,gstNumber,kycType,houseNumber;
  // office details
  String? officeNumber, officeZip, officeArea, officeLandmark, officeState, officeCity ;
  // Documents
  String? panCardUrl, kycUrl, gstUrl, dlUrl,vendorUrl ;
  BankDetails? bankDetails;
  UserModel({
   required this.id,
   required this.name,
   required this.email,
   this.mobileno,
   this.country,
    this.state,
    this.city,
    this.zip,
    this.panCardNumber,
    this.callingNumber,
    this.landmark,
    this.area,
    this.houseNumber,
    this.kycType,
    this.kycNumber,
    this.gstNumber,
  //Office details
    this.officeArea,
    this.officeCity,
    this.officeLandmark,
    this.officeNumber,
    this.officeState,
    this.officeZip,
  //Document details
    this.panCardUrl,
    this.gstUrl,
    this.kycUrl,
    this.vendorUrl,
    this.dlUrl,
    this.bankDetails

});

  factory UserModel.fromJson(Map json){
    BankDetails? details;
    if(json["vendor_details"]==null){
      return UserModel(
        id: json["data"]["id"].toString(),
        name: json["data"]["name"].toString(),
        email: json["data"]["email"].toString(),
        mobileno: json["data"]["mobile"],
        country: json["data"]["country"],
      );
    }
    if(json["bank_details"]!=null){
      details = BankDetails.fromJson(json["bank_details"]);
    }
    return UserModel(
      id: json["data"]["id"].toString(),
      name: json["data"]["name"].toString(),
      email: json["data"]["email"].toString(),
      mobileno: json["data"]["mobile"],
      country: json["data"]["country"],
      state: json["vendor_details"]["state"]??"Not set",
      city: json["vendor_details"]["city"],
      area: json["vendor_details"]["area"],
      zip: json["vendor_details"]["pin_code"],
      landmark: json["vendor_details"]["landmark"],
      panCardNumber: json["vendor_details"]["pan_card"],
      callingNumber: json["vendor_details"]["calling_no"],
      houseNumber: json["vendor_details"]["house_no"],
      kycNumber: json["vendor_details"]["kyc_no"],
      kycType: json["vendor_details"]["kyc_type"],
      gstNumber: json["vendor_details"]["gst_no"],
      officeZip: json["vendor_details"]["office_pincode"],
      officeNumber: json["vendor_details"]["office_house_no"],
      officeArea: json["vendor_details"]["office_area"],
      officeLandmark: json["vendor_details"]["office_landmark"],
      officeCity: json["vendor_details"]["office_city"],
      officeState: json["vendor_details"]["office_state"],
      panCardUrl: '${json["pan_image_link"]}${json["vendor_details"]["pan_image"]}',
      gstUrl: '${json["gst_image"]}${json["vendor_details"]["gst_image"]}',
      kycUrl: '${json["kyc_image"]}${json["vendor_details"]["kyc_image"]}',
      vendorUrl: '${json["vendor_image"]}${json["vendor_details"]["vendor_image"]}',
      dlUrl: '${json["dl_image"]}${json["vendor_details"]["dl_image"]}',
      bankDetails: details
    );

  }
}
