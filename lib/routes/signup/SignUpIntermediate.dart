import 'dart:io';

import 'package:csc_picker/csc_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/routes/service/singleServiceAdd.dart';

import '../../core/components/CountryPicker.dart';
import '../../core/components/CustomDivider.dart';
import '../../core/components/HtmlInputBox.dart';
import '../../core/components/appToolbar.dart';
import '../../core/components/customBox.dart';
import '../../core/components/gradientButton.dart';
import '../../core/components/loading.dart';
import '../../core/models/dropdown.dart';
import '../../core/models/user.dart';
import '../../core/provider/AuthProvider.dart';
import '../../core/provider/RegisterProvider.dart';
import '../../core/provider/ServiceProvider.dart';
import '../../core/provider/mapProvider.dart';
import '../../core/repo/auth.dart';
import '../../core/utils/UIColor.dart';
import '../../core/utils/logger.dart';

class SignUpIntermediate extends StatefulWidget {
  const SignUpIntermediate({Key? key}) : super(key: key);

  @override
  State<SignUpIntermediate> createState() => _SignUpIntermediateState();
}

class _SignUpIntermediateState extends State<SignUpIntermediate> {
  String serviceOption = "Select Service", serviceId = "";

  final _formKey = GlobalKey<FormState>();
  bool showLocationList = false;
  bool isLoading = false;
  TextEditingController _serviceDescription = TextEditingController();
  TextEditingController _materialDescription = TextEditingController();
  TextEditingController _companyName = TextEditingController();
  TextEditingController _videoLink = TextEditingController();
  TextEditingController _officePinCode = TextEditingController();
  TextEditingController _officeNo = TextEditingController();
  TextEditingController _officePhone = TextEditingController();
  TextEditingController _officeArea = TextEditingController();
  TextEditingController _officeLandmark = TextEditingController();
  TextEditingController _GST = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _driverName = TextEditingController();
  TextEditingController _driverMob = TextEditingController();
  TextEditingController _driverKycType = TextEditingController();
  TextEditingController _driverKycNo = TextEditingController();
  TextEditingController _driverLicense = TextEditingController();
  TextEditingController _driverpinCode = TextEditingController();
  TextEditingController _driverhouseNo = TextEditingController();
  TextEditingController _driverArea = TextEditingController();
  TextEditingController _driverLandmark = TextEditingController();
  TextEditingController _driverCity = TextEditingController();
  TextEditingController _driverState = TextEditingController();

  //TextEditingController _driverState = TextEditingController();
  TextEditingController _address= TextEditingController();
  TextEditingController _pin_code= TextEditingController();

  late DropDownField selectedKyc = DropDownField(title: "Aadhar", value: "AD");
  late Future _getCacheData;
  Future _getLocation = Future.value({});
  List<AddProductPhoto> productImages = [];
  String? driverImage, drivingLicenseImage;
  String? videoPath;
  List<String> dataKeys = [
    "category_id",
    "service_id",
    "service_desc",
    "material_desc",
    "office_pincode",
    "office_house_no",
    "office_area",
    "office_country",
    "office_landmark",
    "office_city",
    "office_state",
    "price",
    "driver_name",
    "driver_mobile_no",
    "driver_kyc_type",
    "dricer_kyc_no",
    "driver_licence_no",
    "driver_pincode",
    "driver_house_no",
    "driver_area",
    "driver_landmark",
    "driver_city",
    "driver_state",
    "gst_no"
  ];

  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar", value: "AD"),
    DropDownField(title: "Voter Id", value: "VO"),
    DropDownField(title: "Passport", value: "PA"),
    DropDownField(title: "Driving License", value: "DL"),
    /*   DropDownField(title: "Other Govt. Id", value: "OT"), */
  ];

  late Country selectedOfficeCountry;

  Future<void> getDataFromCache() async {
    AuthProvider auth = context.read<AuthProvider>();
    CustomLogger.debug(auth.user);
    selectedOfficeCountry = Country(id: "101", name: "India");
    Map country = {"id": "101", "name": "India"};
    try {
      country = DefaultCountries.where(
              (element) => element["id"] == auth.user!.country?.id).first;
      if (!country.containsKey("id")) {
        country = {"id": "101", "name": "India"};
      }
    } catch (e) {}



    selectedOfficeCountry = Country(id: country["id"], name: country["name"]);
    _officePinCode.text = auth.user!.officeZip ?? "";
    _officeNo.text = auth.user!.officeNumber ?? "";
    _officePhone.text = auth.user!.officePhone ?? "";
    _officeArea.text = auth.user!.officeArea ?? "";
    _officeLandmark.text = auth.user!.officeLandmark ?? "";
    office_city = auth.user!.officeCity ?? "";
    office_state = auth.user!.officeState ?? "";
    office_country = selectedOfficeCountry.name;
    _GST.text = auth.user!.gstNumber ?? "";
    try {
      _driverKycType.text = kyctypes
          .firstWhere((element) =>
      element.value == auth.user!.service?.driverDetails.kycType)
          .title ??
          "";
    } catch (e) {}
    _serviceDescription.text = auth.user!.service?.serviceDescription ?? "";
    _price.text = auth.user!.service?.price ?? "";
    _materialDescription.text = auth.user!.service?.materialDescription ?? "";
    _driverName.text = auth.user!.service?.driverDetails.name ?? "";
    _driverMob.text = auth.user!.service?.driverDetails.mobileNumber ?? "";
    _driverKycNo.text = auth.user!.service?.driverDetails.kycNumber ?? "";
    _driverpinCode.text = auth.user!.service?.driverDetails.pinCode ?? "";
    _driverhouseNo.text = auth.user!.service?.driverDetails.houseNumber ?? "";
    _driverArea.text = auth.user!.service?.driverDetails.area ?? "";
    _driverLandmark.text = auth.user!.service?.driverDetails.landmark ?? "";
    _driverCity.text = auth.user!.service?.driverDetails.landmark ?? "";
    _driverState.text = auth.user!.service?.driverDetails.state ?? "";


    /*added by me*/

    _city = auth.user!.service?.city_id ?? "";
    _state = auth.user!.service?.state_id ?? "";
    _country = auth.user!.service?.country_id ?? "";
    _pin_code.text = auth.user!.service?.pin_code ?? "";
    _address.text = auth.user!.service?.address ?? "";
    _companyName.text = auth.user!.service?.companyName ?? "";
    _videoLink.text = auth.user!.service?.videoUrl ?? "";
    serviceId=auth.user!.service?.serviceId ?? "";
  }


  String pinCode = "";
  String _city = "", _state = "", _country = "";

  String office_pinCode = "";
  String office_city = "", office_state = "", office_country = "";



  @override
  void initState() {
    super.initState();
    _pin_code.addListener(() {
      if (_pin_code.text.length >= 6)
        setState(() {
          pinCode = _pin_code.text;
        });
    });
    _officePinCode.addListener(() {
      if (_officePinCode.text.length >= 6)
        setState(() {
          office_pinCode = _officePinCode.text;
        });
    });

    _getCacheData = getDataFromCache();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              DropDownOptionProvider(auth: Provider.of<AuthProvider>(context)),
        ),
        ChangeNotifierProvider(create: (_) => MapProvider())
      ],
      child: Consumer2<DropDownOptionProvider, AuthProvider>(
          builder: (context, state, regState, child) {
            if (regState.isLoading || state.isLoading) {
              return LoadingWidget();
            }

            return FutureBuilder(
                future: Future.wait([_getCacheData]),
                builder: (context, snapshot) {
                  return Consumer<MapProvider>(
                    builder: (context, mapState, child) => Scaffold(
                      extendBodyBehindAppBar: false,
                      backgroundColor: UIColor.screen_bg,
                      appBar: AppToolbar(
                        toolbarTitle: "Office Details",
                        onPressed: () {
                          regState.setRegisterProgress(RegisterProgress.two);
                        },
                      ),
                      body: Form(
                        key: _formKey,
                        child: Container(
                          padding: EdgeInsets.all(11),
                          height: double.infinity,
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: Column(children: [
                              CustomMaterialBox(
                                  heading: "Service Details",
                                  listOfChildren: [
                                    Padding(
                                      padding: textInputPadding,
                                      child: ExpansionTile(
                                        collapsedShape: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1, color: Colors.grey),
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        shape: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: UIColor.theme_color),
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                        textColor: UIColor.black_text_color,
                                        iconColor: Colors.grey,
                                        collapsedIconColor: Colors.grey,
                                        collapsedTextColor:
                                        UIColor.black_text_color,
                                        key: GlobalKey(),
                                        title: Text(
                                          serviceId.isEmpty ? serviceOption : state.options!.serviceOptions.firstWhere((item) => item.id== serviceId).service ,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        children: state.options!.serviceOptions
                                            .map(
                                              (e) => ListTile(
                                            title: Text(
                                              e.service,
                                              style: TextStyle(
                                                  color:
                                                  UIColor.black_text_color),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                serviceOption = e.service;
                                                serviceId = e.id;
                                              });
                                            },
                                          ),
                                        )
                                            .toList(),
                                      ),
                                    ),
                                    HtmlInputBox(
                                        text: _serviceDescription.text,
                                        onTextChange: (text) =>
                                        {_serviceDescription.text = text}),
                                    /*  InputField(
                                "Service Description", _serviceDescription,
                                leading: Icon(
                                  Icons.description,
                                  color: UIColor.prefix_icon_tint,
                                )),*/
                                    InputField("Material Description",
                                        _materialDescription,
                                        leading: Icon(
                                          Icons.description_outlined,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                    InputField(
                                        "Company Name (optional)", _companyName,
                                        required: false,
                                        leading: Icon(
                                          Icons.description_outlined,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                    InputField(
                                        "Address", _address,
                                        required: true,
                                        leading: Icon(
                                          Icons.location_city,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                    InputField(
                                        "Pin Code", _pin_code,
                                        isPin: true,
                                        required: true,
                                        leading: Icon(
                                          Icons.location_city,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                    customDivider(),
                                    CountryPicker(
                                        pinCode: pinCode,
                                        state: _state,
                                        city: _city,
                                        country: _country,
                                        onCountryChanged: (country) {
                                          _country = country;
                                        },
                                        onStateChanged: (state) {
                                          _state = state ?? "";
                                        },
                                        onCityChanged: (city) {
                                          _city = city ?? "";
                                        }),


                                    InputField("Video Link", _videoLink,
                                        required: false,
                                        leading: Icon(
                                          Icons.description_outlined,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                    InputField("Price", _price,
                                        isPrice: true,
                                        leading: Icon(
                                          Icons.currency_rupee,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                  ]),
                              customDivider(),
                              CustomMaterialBox(
                                  heading: "Product Image",
                                  listOfChildren: [
                                    Container(
                                      margin: textInputPadding,
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Product Images (3 to 5)",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: UIColor.black_text_color),
                                          ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                if (productImages.length >= 5) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Maximum 5 photos allowed")));
                                                  return;
                                                }
                                                List<XFile?> images =
                                                await ImagePicker()
                                                    .pickMultiImage();
                                                setState(() {
                                                  if (images.length > 5) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "Maximum 5 photos allowed")));
                                                  }
                                                  images.forEach((element) {
                                                    if (productImages.length == 5)
                                                      return;
                                                    productImages.add(
                                                        AddProductPhoto(
                                                            filePath: element?.path,
                                                            id: productImages
                                                                .length,
                                                            onDelete: (id) {
                                                              setState(() {
                                                                productImages
                                                                    .removeWhere(
                                                                        (element) =>
                                                                    element
                                                                        .id ==
                                                                        id);
                                                              });
                                                            }));
                                                  });
                                                });
                                              },
                                              child: const Text("Add"))
                                        ],
                                      ),
                                    ),
                                    ...productImages,
                                  ]),
                              customDivider(),
                              CustomMaterialBox(
                                  heading: "Office Address",
                                  listOfChildren: [
                                    if (serviceOption.toLowerCase().endsWith("car"))
                                      Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 20),
                                            child: Text(
                                              "Driver details",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: UIColor.black_text_color),
                                            ),
                                          ),
                                          InputField("Name", _driverName),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20, top: 30),
                                            child: IntlPhoneField(
                                              initialCountryCode: "IN",
                                              showCountryFlag: false,
                                              dropdownIcon: const Icon(
                                                Icons.arrow_drop_down,
                                                color: UIColor.prefix_icon_tint,
                                              ),
                                              style: TextStyle(
                                                  color: UIColor.black_text_color),
                                              dropdownTextStyle: TextStyle(
                                                  color: UIColor.black_text_color),
                                              decoration: InputDecoration(
                                                label: Text(
                                                  "Phone Number",
                                                  style: TextStyle(
                                                      color:
                                                      UIColor.hint_text_color),
                                                ),
                                              ),
                                              validator: (text) {
                                                if (text == null ||
                                                    text.completeNumber.isEmpty) {
                                                  return "Required field";
                                                }
                                                if (text.completeNumber.length <
                                                    12 ||
                                                    text.completeNumber.length >
                                                        15) {
                                                  return "Please enter a valid number";
                                                }
                                                return null;
                                              },
                                              onChanged: (number) {
                                                _driverMob.text =
                                                    number.completeNumber;
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.person,
                                                    color:
                                                    UIColor.black_text_color),
                                                contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                label: Text(
                                                  "Kyc Type",
                                                  style: TextStyle(
                                                      color:
                                                      UIColor.black_text_color),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(10.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(10.0),
                                                  borderSide: BorderSide(
                                                    color: UIColor.black_text_color,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: ExpansionTile(
                                                        trailing: Text(""),
                                                        key: GlobalKey(),
                                                        title: Text(
                                                          selectedKyc.title,
                                                          style: TextStyle(
                                                              color: UIColor
                                                                  .black_text_color),
                                                        ),
                                                        children: kyctypes
                                                            .map((e) => ListTile(
                                                          onTap: () {
                                                            setState(() {
                                                              _driverKycType
                                                                  .text =
                                                                  e.value;
                                                              selectedKyc = e;
                                                            });
                                                          },
                                                          title: Text(
                                                            e.title,
                                                            style: TextStyle(
                                                                color: UIColor
                                                                    .black_text_color),
                                                          ),
                                                        ))
                                                            .toList(),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                          InputField("${selectedKyc.title} Number",
                                              _driverKycNo,
                                              isAadhar: true),
                                          InputField("License", _driverLicense),
                                          InputField(
                                              "House Number", _driverhouseNo),
                                          InputField("Street/Sector/Village/Area",
                                              _driverArea),
                                          InputField("Landmark", _driverLandmark),
                                          InputField("City", _driverCity),
                                          InputField("PinCode", _driverpinCode,
                                              isPin: true),
                                          InputField("State", _driverState),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            child: Text(
                                              "Choose Driver Image",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: UIColor.black_text_color),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 80,
                                                  height: 60,
                                                  child: driverImage != null
                                                      ? Image.file(
                                                      File(driverImage!))
                                                      : Container(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Container(
                                                  child: ElevatedButton(
                                                    child: const Text("Choose"),
                                                    onPressed: () async {
                                                      XFile? image =
                                                      await ImagePicker()
                                                          .pickImage(
                                                          source:
                                                          ImageSource
                                                              .gallery);
                                                      setState(() {
                                                        driverImage = image?.path;
                                                      });
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            child: Text(
                                              "Choose Driving License Image",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: UIColor.black_text_color),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 80,
                                                  height: 60,
                                                  child: drivingLicenseImage != null
                                                      ? Image.file(File(
                                                      drivingLicenseImage!))
                                                      : Container(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Container(
                                                  child: ElevatedButton(
                                                    child: const Text("Choose"),
                                                    onPressed: () async {
                                                      XFile? image =
                                                      await ImagePicker()
                                                          .pickImage(
                                                          source:
                                                          ImageSource
                                                              .gallery);
                                                      setState(() {
                                                        drivingLicenseImage =
                                                            image?.path;
                                                      });
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),

                                    /*end of service details*/

                                    Container(
                                      child: IntlPhoneField(
                                        initialValue: _officePhone.text,
                                        initialCountryCode: "IN",
                                        showCountryFlag: false,
                                        dropdownIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.grey,
                                        ),
                                        style: TextStyle(
                                            color: UIColor.black_text_color),
                                        dropdownTextStyle: TextStyle(
                                            color: UIColor.black_text_color),
                                        decoration: InputDecoration(
                                          label: Text(
                                            "Phone Number",
                                            style: TextStyle(
                                                color: UIColor.hint_text_color),
                                          ),
                                        ),
                                        validator: (text) {
                                          if (text == null ||
                                              text.completeNumber.isEmpty) {
                                            return "Required field";
                                          }
                                          if (text.completeNumber.length < 12 ||
                                              text.completeNumber.length > 15) {
                                            return "Please enter a valid number";
                                          }
                                          return null;
                                        },
                                        onChanged: (number) {
                                          _officePhone.text = number.completeNumber;
                                        },
                                      ),
                                    ),
                                    InputField("GST Number", _GST,
                                        isCapital: true,
                                        required: false,
                                        leading: Icon(
                                          Icons.numbers,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                    InputField("PinCode", _officePinCode,
                                        leading: Icon(
                                          Icons.pin_drop,
                                          color: UIColor.prefix_icon_tint,
                                        ),
                                        isPin: true),
                                    customDivider(),
                                    CountryPicker(
                                        pinCode: office_pinCode,
                                        state: office_state,
                                        city: office_city,
                                        country: office_country,
                                        onCountryChanged: (country) {
                                          office_country = country;
                                        },
                                        onStateChanged: (state) {
                                          office_state = state ?? "";
                                        },
                                        onCityChanged: (city) {
                                          office_city = city ?? "";
                                        }),
                                    InputField(
                                        "Flat / House / Building Number", _officeNo,
                                        leading: Icon(
                                          Icons.home_filled,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                    InputField(
                                        "Street/Sector/Village/Area", _officeArea,
                                        leading: Icon(
                                          Icons.home_filled,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                    InputField("Landmark", _officeLandmark,
                                        leading: Icon(
                                          Icons.home_filled,
                                          color: UIColor.prefix_icon_tint,
                                        )),
                                  ]),
                              customDivider(),
                              if (isLoading)
                                Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                )
                              else
                                CreateButton(context, regState),
                              customDivider()
                            ]),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }

  Widget CreateButton(BuildContext context, AuthProvider state) {
    return GradientButton(
        text: "Save and Continue",
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          createService(state);
          setState(() {
            isLoading = false;
          });
        });
  }

  Widget InputField(String title, TextEditingController controller,
      {Icon leading = const Icon(
        Icons.person,
        color: UIColor.prefix_icon_tint,
      ),
        bool required = true,
        MapProvider? state,
        bool isAadhar = false,
        bool hide = false,
        bool autoComplete = false,
        bool validatePhone = false,
        bool isCapital = false,
        bool isPin = false,
        bool isPrice = false}) {
    if (validatePhone) {
      if (!controller.text.startsWith("+91"))
        controller.text = "+91" + controller.text;
    }
    return Container(
      margin: textInputPadding,
      child: TextFormField(
        keyboardType: validatePhone || isPin || isPrice
            ? TextInputType.phone
            : TextInputType.text,
        textCapitalization:
        isCapital ? TextCapitalization.characters : TextCapitalization.none,
        obscureText: hide,
        controller: controller,
        onChanged: autoComplete
            ? (text) {
          state!.getLocations(text);
          setState(() {
            showLocationList = true;
          });
        }
            : null,
        style: TextStyle(color: UIColor.black_text_color),
        decoration: InputDecoration(
          prefixIcon: leading,
          label: Text(
            title,
            style: TextStyle(color: UIColor.hint_text_color),
          ),
        ),
        validator: required
            ? (text) {
          if (text == null || text.length == 0) {
            return "Required field";
          }
          if (isAadhar) {
            if (text.length < 12) {
              return "Please enter a valid Aadhar number";
            }
          }
          if (validatePhone) {
            if (text.length < 10 || text.length > 15) {
              return "Please enter a valid phone number";
            }
          }
          if (isPin) {
            if (text.length != 6) {
              return "Please enter a 6 digit pin code";
            }
          }
          return null;
        }
            : null,
      ),
    );
  }

  void createService(AuthProvider state) async {
    if (_formKey.currentState!.validate()) {
      if (serviceId.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Please select a service")));
        return;
      }
      if (_officePhone.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter office number")));
        return;
      }
      Map<String, dynamic> data = {

        /* service related data */

        "service_id": serviceId,
        "service_desc": _serviceDescription.text,
        "material_desc": _materialDescription.text,
        "address": _address.text,
        "pin_code" : _pin_code.text,
        "city": _city,
        "state": _state,
        "country": _country,
        "company_name": _companyName.text,
        "video_url": _videoLink.text,
        "price": _price.text, //
        /*office related data */


        "office_pincode": _officePinCode.text,
        "office_house_no": _officeNo.text,
        "office_mobile": _officePhone.text,
        "office_area": _officeArea.text,
        "office_landmark": _officeLandmark.text,
        "office_city": office_city,
        "office_state": office_state,
        "office_country": office_country,
        "gst_no": _GST.text,

        "driver_name": _driverName.text,
        "driver_mobile_no": _driverMob.text,
        "driver_kyc_type": _driverKycType.text,
        "dricer_kyc_no": _driverKycNo.text,
        "driver_licence_no": _driverLicense.text,
        "driver_pincode": _driverpinCode.text,
        "driver_house_no": _driverhouseNo.text,
        "driver_area": _driverArea.text,
        "driver_landmark": _driverLandmark.text,
        "driver_city": _driverCity.text,
        "driver_state": _driverState.text,
        "vendor_reg_part": 4,
        "img6": driverImage == null
            ? null
            : await MultipartFile.fromFile(driverImage!),
        "img5": drivingLicenseImage == null
            ? null
            : await MultipartFile.fromFile(drivingLicenseImage!),
        "video":
        videoPath == null ? null : await MultipartFile.fromFile(videoPath!),

      };
      for (int i = 0; i < productImages.length; i++) {
        data['pmg${i + 1}'] = productImages[i].filePath == null
            ? null
            : await MultipartFile.fromFile(productImages[i].filePath!);
      }
      CustomLogger.debug(data);
      try {
        await completeRegistrationIntermediate(state, data);
        state.setRegisterProgress(RegisterProgress.four);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Service created successfully")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}