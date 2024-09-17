import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:utsavlife/core/components/CountryPicker.dart';
import 'package:utsavlife/core/components/appToolbar.dart';
import 'package:utsavlife/core/components/customBox.dart';
import 'package:utsavlife/core/components/gradientButton.dart';
import 'package:utsavlife/core/components/loading.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/RegisterProvider.dart';
import 'package:utsavlife/core/provider/mapProvider.dart';
import 'package:utsavlife/core/repo/auth.dart';
import 'package:utsavlife/core/repo/maps.dart';
import 'package:utsavlife/core/utils/Constant.dart';
import 'package:utsavlife/core/utils/UIColor.dart';
import 'package:utsavlife/core/utils/geolocator.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/core/utils/textformatters.dart';
import 'package:utsavlife/core/utils/validator.dart';
import 'package:utsavlife/routes/mainpage.dart';
import 'package:utsavlife/routes/service/singleServiceAdd.dart';
import 'package:utsavlife/routes/terms_privacy.dart';

import '../../core/components/HtmlInputBox.dart';
import '../../core/components/inputFields.dart';
import '../../core/models/dropdown.dart';
import '../../core/provider/ServiceProvider.dart';
import '../signIn.dart';
import 'SignUpIntermediate.dart';

const EdgeInsets textInputPadding =
EdgeInsets.symmetric(vertical: 8, horizontal: 0);
class SignUp3 extends StatefulWidget {
  const SignUp3({Key? key}) : super(key: key);

  @override
  State<SignUp3> createState() => _SignUp3State();
}

class _SignUp3State extends State<SignUp3> {
  final _formKey = GlobalKey<FormState>();
  List<DropDownField> AccountTypes = [
    DropDownField(title: "Current Account", value: "current"),
    DropDownField(title: "Savings Account", value: "saving"),
    DropDownField(title: "Salary Account", value: "salary"),
    DropDownField(title: "Fixed Deposit Account", value: "fixed"),
    DropDownField(title: "Recurring Deposit Account", value: "recurring"),
    DropDownField(title: "NRI Account", value: "nri"),
  ];
  TextEditingController _bankName = TextEditingController();
  TextEditingController _AccountType = TextEditingController();
  TextEditingController _AccountNo = TextEditingController();
  TextEditingController _AccountNoConfirm = TextEditingController();
  TextEditingController _IFSCNo = TextEditingController();
  TextEditingController _HolderName = TextEditingController();
  TextEditingController _BranchName = TextEditingController();
  late DropDownField selectedAccount = AccountTypes[0];
  String? passbookPath;
  bool isLoading = false;
  late Future _getCacheData;
  List<String> dataKeys = [
    "bank_name",
    "acc_no",
    "ifsc_no",
    "holder_name",
    "branch_name",
    "acc_type"
  ];

  @override
  void initState() {
    super.initState();
    _getCacheData = getDataFromCache();
  }

  Future<void> getDataFromCache() async {
    AuthProvider auth = context.read<AuthProvider>();
    selectedAccount = AccountTypes.firstWhere(
            (element) => element.value == auth.user!.bankDetails?.accountType,
        orElse: () => AccountTypes[0]);
    _AccountType.text = selectedAccount.value;
    _bankName.text = auth.user!.bankDetails?.bankName ?? "";
    _AccountNo.text = auth.user!.bankDetails?.accountNumber ?? "";
    _IFSCNo.text = auth.user!.bankDetails?.ifscNumber ?? "";
    _HolderName.text = auth.user!.bankDetails?.holderName ?? "";
    _BranchName.text = auth.user!.bankDetails?.bankName ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, state, child) {
      return FutureBuilder(
          future: _getCacheData,
          builder: (context, snapshot) {
            return Scaffold(
              extendBodyBehindAppBar: false,
              backgroundColor: UIColor.screen_bg,
              appBar: AppToolbar(
                toolbarTitle: "Bank details",
                onPressed: () {
                  state.setRegisterProgress(RegisterProgress.three);
                },
              ),
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(
                      children: [
                        customDivider(),
                        CustomMaterialBox(listOfChildren: [
                          InputField("Bank Name", _bankName,
                              leading: Icon(
                                Icons.currency_rupee,
                                color: UIColor.black_text_color,
                              )),
                          Container(
                            padding: textInputPadding,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person,
                                    color: UIColor.prefix_icon_tint),
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                                label: Text(
                                  "Kyc Type (optional)",
                                  style: TextStyle(color: UIColor.hint_text_color),
                                ),
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: UIColor.prefix_icon_tint,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: UIColor.theme_color,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: ExpansionTile(
                                        collapsedTextColor: UIColor.black_text_color,
                                        trailing: Text(""),
                                        key: GlobalKey(),
                                        title: Text(selectedAccount.title),
                                        children: AccountTypes.map((e) => ListTile(
                                          onTap: () {
                                            setState(() {
                                              _AccountType.text = e.value;
                                              selectedAccount = e;
                                            });
                                          },
                                          title: Text(
                                            e.title,
                                            style: TextStyle(
                                                color: UIColor.hint_text_color),
                                          ),
                                        )).toList(),
                                      ))
                                ],
                              ),
                            ),
                          ),
                          InputField("Account Number", _AccountNo,
                              isAccountNumber: true),
                          InputField("Re-Enter Account Number", _AccountNoConfirm,
                              accountConfirm: true),
                          InputField("IFSC Code", _IFSCNo),
                          InputField("Holder Name", _HolderName),
                          InputField("Branch Name", _BranchName,
                              leading: Icon(
                                Icons.home_outlined,
                                color: UIColor.prefix_icon_tint,
                              )),
                          customDivider(),
                          Container(
                            padding: textInputPadding,
                            child: Row(
                              children: [
                                Expanded(
                                    child: passbookPath == null
                                        ? Text(
                                      "Cancelled Checkbook / Passbook Front page",
                                      style: TextStyle(
                                          color: UIColor.black_text_color),
                                    )
                                        : Container(
                                        alignment: Alignment.centerLeft,
                                        height: 80,
                                        width: 80,
                                        child:
                                        Image.file(File(passbookPath!)))),
                                SizedBox(
                                  width: 40,
                                ),
                                OutlinedButton(
                                    onPressed: () async {
                                      XFile? file = await ImagePicker()
                                          .pickImage(source: ImageSource.gallery);
                                      if (file != null) {
                                        setState(() {
                                          passbookPath = file.path;
                                        });
                                      }
                                    },
                                    child: Text(
                                        passbookPath == null ? "Choose" : "Change"))
                              ],
                            ),
                          ),
                        ]),
                        customDivider(),
                        if (isLoading)
                          Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          )
                        else
                          SignUpButton(context, state),
                      ],
                    )),
              ),
            );
          });
    });
  }

  Future<void> submit(AuthProvider state) async {
    if (_formKey.currentState!.validate()) {
      if (passbookPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Please Upload a cancelled Check or a passbook front page.")));
        setState(() {
          isLoading = false;
        });
        return;
      }
      Map<String, dynamic> data = {
        "bank_name": _bankName.text,
        "acc_no": _AccountNo.text,
        "ifsc_no": _IFSCNo.text,
        "holder_name": _HolderName.text,
        "branch_name": _BranchName.text,
        "acc_type": _AccountType.text,
        "img1": await MultipartFile.fromFile(passbookPath!),
        "vendor_reg_part": 5
      };
      setState(() {
        isLoading = false;
      });

      CustomLogger.debug(data);

      await completeRegistration2(state, data);
      state.setRegisterProgress(RegisterProgress.five);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your data has been successfully recorded.")));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget SignUpButton(BuildContext context, AuthProvider state) {
    return Row(
      children: [
        Expanded(
            child: GradientButton(
                text: "Skip",
                colors: [UIColor.error_color, UIColor.error_color],
                onPressed: () =>
                    state.setRegisterProgress(RegisterProgress.five))),
        Expanded(
          child: GradientButton(
              text: "Save and Continue",
              onPressed: () async {
                try {
                  setState(() {
                    isLoading = true;
                  });
                  await submit(state);
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  CustomLogger.error(e);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }),
        ),
      ],
    );
  }

  Widget InputField(String title, TextEditingController controller,
      {Icon leading = const Icon(
        Icons.person,
        color: UIColor.prefix_icon_tint,
      ),
        bool hide = false,
        bool autocomplete = true,
        bool isAccountNumber = false,
        bool accountConfirm = false}) {
    return Container(
      margin: textInputPadding,
      child: TextFormField(
          keyboardType:
          accountConfirm ? TextInputType.number : TextInputType.text,
          obscureText: hide,
          controller: controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (text) {
            if (text?.length == 0) return "$title is required";

            if(isAccountNumber && (_AccountNo.text.length < 8 || _AccountNo.text.length > 20)){
              return "Enter Valid Account Number 8-20 digits";
            }

            if (accountConfirm) {
              if (_AccountNo.text.length < 8 || _AccountNo.text.length > 20)
                return "Enter Valid Account Number 8-20 digits";
              if (_AccountNo.text != _AccountNoConfirm.text)
                return "Account Numbers do not match";
            }
            return null;
          },
          style: TextStyle(color: UIColor.black_text_color),
          decoration: InputDecoration(
            prefixIcon: leading,
            label: Text(
              title,
              style: TextStyle(color: UIColor.hint_text_color),
            ),
          )),
    );
  }
}