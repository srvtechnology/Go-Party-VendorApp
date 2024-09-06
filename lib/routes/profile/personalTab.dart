import 'package:cached_network_image/cached_network_image.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/gradientButton.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/UIColor.dart';
import 'package:utsavlife/routes/profile/custom_text_widget.dart';

import '../../core/components/CountryPicker.dart';
import '../../core/models/dropdown.dart';
import '../../core/models/user.dart';
import 'Constants.dart';

class Personaltab extends StatefulWidget {
  const Personaltab({super.key});

  @override
  State<Personaltab> createState() => _PersonaltabState();
}

class _PersonaltabState extends State<Personaltab> {
  void setUserProfileChanges(AuthProvider auth) {
    auth.user!.name = textControllers[Constants.nameKey]!.text;
    auth.user!.panCardNumber =
        textControllers[Constants.panCardNumberKey]!.text;
    auth.user!.mobileno = textControllers[Constants.phoneKey]!.text;
    auth.user!.kycNumber = textControllers[Constants.kycNumberKey]!.text;
    auth.user!.kycType =
        selectedKyc.value; // Assuming selectedKyc is defined elsewhere
    auth.user!.zip = textControllers[Constants.pinCodeKey]!.text;
    auth.user!.area = textControllers[Constants.areaKey]!.text;
    auth.user!.landmark = textControllers[Constants.landmarkKey]!.text;

    auth.user!.houseNumber = textControllers[Constants.houseNumberKey]!.text;

    auth.user!.callingNumber =
        textControllers[Constants.callingNumberKey]!.text;

    auth.user!.country = selectedCountry;
    auth.user!.state = _state;
    auth.user!.city = _city;
  }

  Map<String, TextEditingController> textControllers = {
    Constants.emailKey: TextEditingController(),
    Constants.phoneKey: TextEditingController(),
    Constants.nameKey: TextEditingController(),
    Constants.panCardNumberKey: TextEditingController(),
    Constants.kycNumberKey: TextEditingController(),
    Constants.kycTypeKey: TextEditingController(),
    Constants.pinCodeKey: TextEditingController(),
    Constants.addressKey: TextEditingController(),
    Constants.areaKey: TextEditingController(),
    Constants.landmarkKey: TextEditingController(),
    Constants.houseNumberKey: TextEditingController(),
    Constants.callingNumberKey: TextEditingController(),
  };

  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar", value: "AD"),
    DropDownField(title: "Voter Id", value: "VO"),
    DropDownField(title: "Passport", value: "PA"),
    DropDownField(title: "Driving License", value: "DL"),
  ];

  late Country selectedCountry = Country(id: "101", name: "India");
  bool ProfileEditMode = false;

  GlobalKey<FormState> _formKey = GlobalKey();
  late DropDownField selectedKyc = kyctypes[0];

  bool isLoading = false;
  String? profileImageLocal;

  String pinCode = "";
  String _city = "", _state = "";

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = !isLoading;
    });

    Provider.of<AuthProvider>(context, listen: false).getUser();
    setState(() {
      isLoading = !isLoading;
    });
    selectedKyc = kyctypes.firstWhere(
        (element) =>
            element.value ==
            Provider.of<AuthProvider>(context, listen: false).user?.kycType,
        orElse: () => kyctypes[0]);
    selectedCountry =
        Provider.of<AuthProvider>(context, listen: false).user?.country ??
            Country(id: "101", name: "India");
    _city=
        Provider.of<AuthProvider>(context, listen: false).user?.city ?? "";
    _state = Provider.of<AuthProvider>(context, listen: false).user?.state ?? "";
    textControllers[Constants.pinCodeKey]!.text = Provider.of<AuthProvider>(context, listen: false).user?.zip ?? "";

    textControllers[Constants.pinCodeKey]!.addListener(() {
      if (textControllers[Constants.pinCodeKey]!.text.length >= 6)
        setState(() {
          pinCode = textControllers[Constants.pinCodeKey]!.text;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                children: [
                  SizedBox(height: 20,),
                 if(ProfileEditMode) Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          ProfileEditMode =!ProfileEditMode;
                        });
                      },
                      icon: Image.asset(
                        'assets/images/back_arrow.png',
                        height: 25,
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      CircleAvatar(
                          radius: 50,
                          child: profileImageLocal != null
                              ? CircularProgressIndicator.adaptive(
                                  backgroundColor: Colors.white,
                                )
                              : SizedBox(),
                          backgroundImage: CachedNetworkImageProvider(
                              profileImageLocal == null
                                  ? auth.user!.vendorUrl == null
                                      ? ""
                                      : auth.user!.vendorUrl!
                                  : profileImageLocal!)),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 35,
                          // Adjust height to match the size of the icon and padding
                          width: 35,
                          // Ensure width is equal to height to maintain circular shape
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () async {
                                XFile? file = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                if (file != null) {
                                  setState(() {
                                    profileImageLocal = file.path;
                                  });
                                  await auth.editProfileImage(
                                      profilePath: file.path);
                                  await auth.getUser();

                                  setState(() {
                                    profileImageLocal = null;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 20, // Adjust icon size
                                color: Colors.blue, // Change color if needed
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  CustomText(context,
                      textControllers: textControllers,
                      editMode: ProfileEditMode,
                      title: "Name",
                      content: auth.user!.name ?? "Not yet",
                      canEdit: false),
                  CustomText(context,
                      editMode: ProfileEditMode,
                      textControllers: textControllers,
                      title: "Phone Number",
                      controllerKey: Constants.phoneKey,
                      content: auth.user!.mobileno ?? "",
                      validatePhone: true),
                  CustomText(context,
                      textControllers: textControllers,
                      editMode: ProfileEditMode,
                      title: "Email",
                      content: auth.user!.email,
                      canEdit: false),
                  CustomText(context,
                      textControllers: textControllers,
                      editMode: ProfileEditMode,
                      controllerKey: Constants.panCardNumberKey,
                      title: "Pan Number",
                      content: auth.user!.panCardNumber ?? "",
                      capitals: true),
                  if (ProfileEditMode)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 45),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(Constants.kycTypeKey),
                          DropdownButton(
                            value: selectedKyc,
                            items: kyctypes
                                .map((e) => DropdownMenuItem(
                                      child: Text(e.title),
                                      value: e,
                                    ))
                                .toList(),
                            onChanged: (_) {
                              setState(() {
                                textControllers[Constants.kycTypeKey]?.text =
                                    _!.value;
                                selectedKyc = _!;
                                textControllers[Constants.kycNumberKey]?.text =
                                    "";
                                auth.user!.kycNumber = "";
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    CustomText(context,
                        editMode: ProfileEditMode,
                        title: Constants.kycTypeKey,
                        textControllers: textControllers,
                        content: kyctypes
                                .firstWhere(
                                    (element) =>
                                        element.value == auth.user!.kycType,
                                    orElse: () => kyctypes[0])
                                .title ??
                            "",
                        canEdit: false),
                  CustomText(context,
                      textControllers: textControllers,
                      editMode: ProfileEditMode,
                      controllerKey: Constants.kycNumberKey,
                      title: "${selectedKyc.title} Number",
                      content: auth.user!.kycNumber ?? ""),
                  if (ProfileEditMode)
                    Column(
                      children: [
                        CustomText(context,
                            editMode: ProfileEditMode,
                            textControllers: textControllers,
                            title: "PinCode",
                            content: textControllers[Constants.pinCodeKey]!.text ?? "",
                            isPin: true),
                        CustomText(context,
                            textControllers: textControllers,
                            editMode: ProfileEditMode,
                            controllerKey: Constants.houseNumberKey,
                            title: "Flat / House / Building Number",
                            content: auth.user!.area ?? ""),
                        CustomText(context,
                            textControllers: textControllers,
                            editMode: ProfileEditMode,
                            controllerKey: Constants.areaKey,
                            title: "Street/Sector/Village/Area",
                            content: auth.user!.area ?? ""),
                        CustomText(context,
                            editMode: ProfileEditMode,
                            textControllers: textControllers,
                            title: Constants.landmarkKey,
                            content: auth.user!.landmark ?? ""),
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child:   CountryPicker(
                                pinCode: pinCode,
                                state: _state,
                                city: _city,
                                country: selectedCountry.name,
                                onCountryChanged: (country) {
                                  selectedCountry =   Country(id: "101", name: country);;
                                },
                                onStateChanged: (state) {
                                  _state = state ?? "";
                                },
                                onCityChanged: (city) {
                                  _city = city ?? "";
                                }),),
                        CustomText(context,
                            textControllers: textControllers,
                            editMode: ProfileEditMode,
                            controllerKey: Constants.callingNumberKey,
                            title: Constants.callingNumberKey,
                            content: auth.user!.callingNumber ?? "",
                            capitals: true),
                      ],
                    )
                  else
                    CustomText(context,
                        title: "Address",
                        textControllers: textControllers,
                        content:
                            "${auth.user!.houseNumber}, ${auth.user!.landmark ?? "hu"}, ${auth.user!.area ?? ""}, ${auth.user!.city ?? ""}, ${auth.user!.zip ?? ""}, ${auth.user!.state ?? ""},${auth.user!.country?.name ?? "India"}",
                        editMode: ProfileEditMode),
                  SizedBox(
                    height: 20,
                  ),
                  if (ProfileEditMode)
                    isLoading
                        ? CircularProgressIndicator.adaptive(
                            backgroundColor: UIColor.theme_color,
                          )
                        : GradientButton(
                            text: "Save",
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_state
                                    .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Please select state")));
                                  return;
                                }
                                if (_city
                                    .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Please select city")));
                                  return;
                                }

                                setState(() {
                                  isLoading = !isLoading;
                                });
                                setUserProfileChanges(auth);
                                await auth.editProfile();
                                setState(() {
                                  isLoading = !isLoading;
                                  ProfileEditMode = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Successfully updated")));
                              }
                            }),
                  if (!ProfileEditMode)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(15),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(color: UIColor.theme_color),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              padding: EdgeInsets.all(15)),
                          onPressed: () {
                            setState(() {
                              ProfileEditMode = !ProfileEditMode;
                            });
                          },
                          child: Text(
                            "Edit Profile Details",
                            style: TextStyle(color: UIColor.theme_color),
                          )),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
