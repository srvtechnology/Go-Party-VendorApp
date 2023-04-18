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
