class UserModel {
  String id,name,email;
  String? mobileno,country,state,city,zip;
  UserModel({
   required this.id,
   required this.name,
   required this.email,
   this.mobileno,
   this.country,
    this.state,
    this.city,
    this.zip
});

  factory UserModel.fromJson(Map json){
    return UserModel(
        id: json["id"].toString(),
        name: json["name"].toString(),
        email: json["email"].toString(),
        mobileno: json["mobile"],
        country: json["country"],
        state: json["state"],
        city: json["city"]
    );
  }
}
