import 'package:flutter/cupertino.dart';
import 'package:utsavlife/core/repo/maps.dart' as mapRepo ;
class Coordinates{
  String latitude;
  String longitude;
  Coordinates({required this.longitude,required this.latitude});
}
class MapProvider with ChangeNotifier {
  List<String> _locations =[];
  Coordinates _coordinates=Coordinates(longitude: "", latitude: "");
  List<String> get locations => _locations ;
  Coordinates get coordinates=> _coordinates;

  void getLocations(String location)async{
    _locations = await mapRepo.autoCompleteLocation(location);
    notifyListeners();
  }
  Future<void> getLatLong(String location)async{
    try{
      Map data = await mapRepo.getLatitudeLongitude(location);
      _coordinates = Coordinates(longitude: data["long"], latitude: data["lat"]);
      notifyListeners();
    }catch(e){
      return Future.error(e);
    }
  }
}