import 'package:dio/dio.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/utils/logger.dart';

Future<List<String>> autoCompleteLocation(String location)async{
  try{
    Response response = await Dio().get("https://maps.googleapis.com/maps/api/place/autocomplete/json",
    queryParameters: {
      "key":APIConfig.googleKey,
      "input":location
    }
  );
  List<String> locations =[];
  for(var i in response.data["predictions"]){
    locations.add(i["description"]);
  }
  return locations;
  }
   catch(e){
    CustomLogger.error(e);
    return Future.error(e);
   }
}

Future<Map<String,String>> getLatitudeLongitude(String location)async{
  try{
    Response response = await Dio().get("https://maps.googleapis.com/maps/api/geocode/json",
        queryParameters: {
          "key":APIConfig.googleKey,
          "address":location
        }
    );
    Map data = response.data["results"][0]["geometry"]["location"];
    CustomLogger.debug(data);
    Map<String,String> latlong={
      "lat":data["lat"].toString(),
      "long":data["lng"].toString()
    };
    return latlong;
  }
  catch(e){
    return Future.error(e);
  }
}

Future<Map<String,String>> getCountryStateCityfromZip(String zipcode)async{
  try{
    Response response = await Dio().get("https://maps.googleapis.com/maps/api/geocode/json",
        queryParameters: {
          "key":APIConfig.googleKey,
          "components":"postal_code:${zipcode}"
        }
    );
    Map<String,String> data={};
    for (var i in response.data["results"][0]["address_components"]){
      if (i["types"].contains("locality")){
        data["city"]=i["long_name"];
      }
      else if(i["types"].contains("administrative_area_level_1")){
        data["state"]=i["long_name"];
      }
      else if(i["types"].contains("country")){
        data["country"]=i["long_name"];
      }
    }
    return data;
  }
  catch(e){
    return Future.error(e);
  }
}
