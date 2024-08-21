import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // Import your IntlPhoneField package
import 'package:dropdown_search/dropdown_search.dart'; // Import your DropdownSearch package
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/models/user.dart';

class CustomText extends StatefulWidget {
  final String title;
  final String? controllerKey;
  final String content;
  final bool editMode;
  final bool canEdit;
  final bool capitals;
  final bool accountConfirm;
  final bool validatePhone;
  final bool isCountry;
  final bool personal;
  final bool isPin;
  final Map<String, TextEditingController> textControllers;
  final Country? selectedCountry;
  final List<Map<String, dynamic>> defaultCountries;

  final bool isHidden;


  const CustomText(
    BuildContext context, {
    Key? key,
    required this.title,
    this.controllerKey,
    required this.content,
    required this.editMode,
    this.canEdit = true,
    this.capitals = false,
    this.accountConfirm = false,
    this.validatePhone = false,
    this.isCountry = false,
    this.personal = false,
    this.isPin = false,
    required this.textControllers,
    this.selectedCountry,
    this.defaultCountries = const [],
    this.isHidden = false,

  }) : super(key: key);

  @override
  _CustomTextState createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  Country? selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = widget.selectedCountry;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHidden) return Container();

    String controllerKey = widget.controllerKey ?? widget.title;
    String content = widget.content.isEmpty ? "" : widget.content;

    if (widget.validatePhone && widget.editMode) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: IntlPhoneField(
          initialValue: content,
          showCountryFlag: false,
          decoration: InputDecoration(
            labelText: widget.title,
            labelStyle: TextStyle(color: Colors.black, fontSize: 16.sp),
            hintText: "Not set",
            border: const OutlineInputBorder(),
            enabled: (widget.editMode && widget.canEdit),
          ),
          validator: (text) {
            if (text == null || text.completeNumber.isEmpty) {
              return "Required field";
            }
            if (text.completeNumber.length < 12 ||
                text.completeNumber.length > 15) {
              return "Please enter a valid number";
            }
          },
          onChanged: (number) {
            widget.textControllers[controllerKey]?.text = number.completeNumber;
          },
        ),
      );
    }

    widget.textControllers[controllerKey]?.text = content;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: (widget.isCountry && widget.editMode)
          ? Container(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Country",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownSearch<Country>(
                          selectedItem: selectedCountry,
                          onChanged: (country) {
                            setState(() {
                              selectedCountry = country!;
                            });
                          },
                          items: widget.defaultCountries
                              .map((e) => Country(
                                  id: e["id"].toString(), name: e["name"]))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: widget.editMode
                        ? TextFormField(
                            keyboardType: widget.validatePhone ||
                                    widget.accountConfirm ||
                                    widget.isPin
                                ? TextInputType.phone
                                : TextInputType.text,
                            validator: (text) {
                              if (text == null || text.isEmpty)
                                return "Required";

                              /*if (widget.isAccountNumber && text.length < 8) {
                                return "Account number should be at least 8 digit";
                              }*/

                              if (widget.accountConfirm) {
                                if (text.length < 8 || text.length > 20)
                                  return "Enter Valid Account Number";
                              }
                              if (widget.validatePhone) {
                                if (text.length < 10 || text.length > 13)
                                  return "Enter valid Number";
                              }
                              if (widget.isPin) {
                                if (text.length != 6) {
                                  return "Please enter a 6 digit valid pincode";
                                }
                              }
                            },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                            textCapitalization: widget.capitals
                                ? TextCapitalization.characters
                                : TextCapitalization.none,
                            controller: widget.textControllers[controllerKey],
                            decoration: InputDecoration(
                                labelText: widget.title,
                                labelStyle: TextStyle(
                                    color: Colors.black, fontSize: 16.sp),
                                hintText: "Not set",
                                border: const UnderlineInputBorder()),
                            enabled: (widget.editMode && widget.canEdit),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(
                                content,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.sp),
                              ),
                            ],
                          )),
              ],
            ),
    );
  }
}
