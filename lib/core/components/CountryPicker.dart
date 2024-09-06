import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:utsavlife/core/components/customBox.dart';

import '../repo/maps.dart';
import '../utils/UIColor.dart';
import '../utils/logger.dart';

class CountryPicker extends StatefulWidget {
  String country, state, city, pinCode;
  final ValueChanged<String>? onCountryChanged;
  final ValueChanged<String?>? onStateChanged;
  final ValueChanged<String?>? onCityChanged;


  CountryPicker(
      {super.key,
      required this.country,
      required this.state,
      required this.city,
      required this.pinCode, required this.onCountryChanged,required this.onStateChanged, required this.onCityChanged});

  //CountryPicker({super.key,required this.pinCode});

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  Future _locationFuture = Future.value({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.pinCode.length == 6) _locationFuture = _getLocationfromPinCode();
  }

  Future _getLocationfromPinCode() async {
    var data = await getCountryStateCityfromZip(widget.pinCode);
    CustomLogger.debug(data);
    setState(() {
      widget.country = data["country"]!;
      widget.state = data["state"]!;
      widget.city = data["city"]!;
      widget.onCountryChanged?.call(widget.country);
      widget.onCityChanged?.call(widget.city);
      widget.onStateChanged?.call(widget.state);
    });
  }

  @override
  void didUpdateWidget(CountryPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pinCode != widget.pinCode && widget.pinCode.length == 6) {
      setState(() {
        _locationFuture = _getLocationfromPinCode();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FutureBuilder(
        future: _locationFuture,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? SizedBox(
                  width: double.infinity,
                  height: 85,
                  child: Center(child: CircularProgressIndicator()),
                )
              : CSCPicker(
                  flagState: CountryFlag.DISABLE,
                  showStates: true,
                  showCities: true,
                  disabledDropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                    color: Colors.transparent,
                  ),
                  currentCountry:
                      widget.country.isEmpty ? null : widget.country,
                  currentCity: widget.city.isEmpty ? null : widget.city,
                  currentState: widget.state.isEmpty ? null : widget.state,
                  selectedItemStyle: TextStyle(color: UIColor.black_text_color),
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                    color: Colors.transparent,
                  ),
                  onCountryChanged: widget.onCountryChanged,
                  onStateChanged: widget.onStateChanged,
                  onCityChanged: widget.onCityChanged,
                );
        },
      )
    ]);
  }
}
