import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/components/gradientButton.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/routes/profile/Constants.dart';

import '../../core/components/CountryPicker.dart';
import '../../core/models/user.dart';
import '../../core/utils/UIColor.dart';
import '../../core/utils/logger.dart';
import 'custom_text_widget.dart';

class officeTab extends StatefulWidget {
  const officeTab({super.key});

  @override
  State<officeTab> createState() => _officeTabState();
}

class _officeTabState extends State<officeTab> {
  GlobalKey<FormState> _officeFormKey = GlobalKey<FormState>();

  Map<String, TextEditingController> textControllers = {
    Constants.officeNumberKey: new TextEditingController(),
    Constants.officePhoneKey: new TextEditingController(),
    Constants.officePinCodeKey: new TextEditingController(),
    Constants.officeAreaKey: new TextEditingController(),
    Constants.officeLandmarkKey: new TextEditingController(),
    Constants.gstNumberKey: TextEditingController(),
  };

  bool OfficeEditMode = false;

  bool isLoading = false;

  void setOfficeChanges(AuthProvider auth) {

    auth.user!.officePhone = textControllers[Constants.officePhoneKey]!.text;
    auth.user!.officeNumber = textControllers[Constants.officeNumberKey]!.text;
    auth.user!.officeZip = textControllers[Constants.officePinCodeKey]!.text;
    auth.user!.officeArea = textControllers[Constants.officeAreaKey]!.text;
    auth.user!.officeLandmark = textControllers[Constants.officeLandmarkKey]!.text;
    auth.user!.officeState = _state;
    auth.user!.officeCity = _city;
    auth.user!.officeCountry = _country;
    auth.user!.gstNumber = textControllers[Constants.gstNumberKey]!.text;
  }

  String pinCode = "";
  String _city = "", _state = "" ,_country ="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    textControllers[Constants.officePinCodeKey]!.addListener(() {
      if (textControllers[Constants.officePinCodeKey]!.text.length >= 6)
        setState(() {
          pinCode = textControllers[Constants.officePinCodeKey]!.text;
        });
    });


    Provider.of<AuthProvider>(context, listen: false).getUser();
    _country =
        Provider.of<AuthProvider>(context, listen: false).user?.officeCountry ?? "India";
    _state=Provider.of<AuthProvider>(context, listen: false).user!.officeState??"";
    _city=Provider.of<AuthProvider>(context, listen: false).user!.officeCity??"";

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Form(
          key: _officeFormKey,
          child: SingleChildScrollView(
            physics: OfficeEditMode
                ? ClampingScrollPhysics()
                : NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 20,),
                if(OfficeEditMode) Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        OfficeEditMode =!OfficeEditMode;
                      });
                    },
                    icon: Image.asset(
                      'assets/images/back_arrow.png',
                      height: 25,
                    ),
                  ),
                ),
                CustomText(context,
                    editMode: OfficeEditMode,
                    textControllers: textControllers,
                    title: "Phone Number",
                    controllerKey: "Office Phone",
                    content: auth.user!.officePhone ?? "",
                    validatePhone: true),

                CustomText(context,
                    textControllers: textControllers,
                    isHidden: false,
                    editMode: OfficeEditMode,
                    controllerKey: Constants.gstNumberKey,
                    title: Constants.gstNumberKey,
                    content: auth.user!.gstNumber ?? "",
                    capitals: true),

                CustomText(context,
                    editMode: OfficeEditMode,
                    textControllers: textControllers,
                    title: "Flat / House / Building Number",
                    controllerKey: "Office Number",
                    content: auth.user!.officeNumber ?? ""),
                CustomText(context,
                    editMode: OfficeEditMode,
                    textControllers: textControllers,
                    title: "Street/Sector/Village/Area",
                    controllerKey: "Office Area",
                    content: auth.user!.officeArea ?? ""),
                CustomText(context,
                    editMode: OfficeEditMode,
                    textControllers: textControllers,
                    title: "Landmark",
                    controllerKey: "Office Landmark",
                    content: auth.user!.officeLandmark ?? ""),
                CustomText(context,
                    editMode: OfficeEditMode,
                    textControllers: textControllers,
                    title: "PinCode",
                    controllerKey: "Office PinCode",
                    content: auth.user!.officeZip ?? "",
                    isPin: true),
                if (OfficeEditMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: CountryPicker(
                        pinCode: pinCode,
                        state: _state,
                        city: _city,
                        country: _country,
                        onCountryChanged: (country) {
                          _country =   country;
                        },
                        onStateChanged: (state) {
                          _state = state ?? "";
                        },
                        onCityChanged: (city) {
                          _city = city ?? "";
                        }),
                  )
                else
                  CustomText(context,
                      title: "Address",
                      textControllers: textControllers,
                      content:
                          "${auth.user!.officeNumber}, ${auth.user!.officeLandmark}, ${auth.user!.officeArea}, ${auth.user!.officeCity}, ${auth.user!.officeZip}, ${auth.user!.officeState}, ${auth.user!.officeCountry ?? ""}",
                      editMode: OfficeEditMode),
                if (OfficeEditMode)
                  isLoading
                      ? CircularProgressIndicator.adaptive(
                    backgroundColor: UIColor.theme_color,
                  )
                      :  GradientButton(text: "Save", onPressed: () async{
                    if (_officeFormKey.currentState!.validate()) {
                      if (_country.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select country")));
                        return;
                      }
                   if (_state.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select state")));
                        return;
                      }
                      if (_city.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select city")));
                        return;
                      }
                      setState(() {
                        isLoading = !isLoading;
                      });
                      setOfficeChanges(auth);
                      await auth.editOfficeDetails();
                      await auth.editProfile();
                      setState(() {
                        OfficeEditMode = false;
                        isLoading = !isLoading;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Successfully updated")));
                    }
                  }),


                if (!OfficeEditMode) Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(15),
                  child: OutlinedButton(

                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: UIColor.theme_color),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.all(15)
                      ),
                      onPressed: () {
                        setState(() {
                          OfficeEditMode = !OfficeEditMode;
                        });
                      }, child: Text("Edit Office Details", style: TextStyle(color: UIColor.theme_color),)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
