import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/gradientButton.dart';
import 'package:utsavlife/core/utils/Constant.dart';
import 'package:utsavlife/routes/profile/Constants.dart';

import '../../core/models/dropdown.dart';
import '../../core/models/user.dart';
import '../../core/provider/AuthProvider.dart';
import '../../core/repo/auth.dart';
import '../../core/utils/UIColor.dart';
import 'custom_text_widget.dart';

class BankTab extends StatefulWidget {
  const BankTab({super.key});

  @override
  State<BankTab> createState() => _BankTabState();
}

class _BankTabState extends State<BankTab> {
  bool BankEditMode = false;
  GlobalKey<FormState> _bankFormKey = GlobalKey<FormState>();
  List<DropDownField> AccountTypes = [
    DropDownField(title: "Current Account", value: "current"),
    DropDownField(title: "Savings Account", value: "saving"),
    DropDownField(title: "Salary Account", value: "salary"),
    DropDownField(title: "Fixed Deposit Account", value: "fixed"),
    DropDownField(title: "Recurring Deposit Account", value: "recurring"),
    DropDownField(title: "NRI Account", value: "nri"),
  ];
  String? passbookLocalPath;
  String? passbookDBPath;
  String passbookUrl = "storage/app/public/vandor/checkbookOrPassbookImage";
  late DropDownField selectedAccountType;
  Map<String, TextEditingController> textControllers = {
    Constants.holderNameKey: new TextEditingController(),
    Constants.bankNameKey: new TextEditingController(),
    Constants.branchNameKey: new TextEditingController(),
    Constants.ifscCodeKey: new TextEditingController(),
    Constants.accountNumberKey: new TextEditingController(),
    Constants.accountTypeKey: new TextEditingController(),
  };
  Future<void> setBankChanges(AuthProvider auth) async {
    Map<String, dynamic> data = {
      "bank_name": textControllers["Bank Name"]?.text,
      "acc_no": textControllers["Account Number"]?.text,
      "ifsc_no": textControllers["IFSC Code"]?.text,
      "holder_name": textControllers["Holder Name"]?.text,
      "branch_name": textControllers["Branch Name"]?.text,
      "acc_type": selectedAccountType.value,
    };
    if (passbookLocalPath != null) {
      data["img1"] = await MultipartFile.fromFile(passbookLocalPath!);
    }
    auth.user?.bankDetails = BankDetails(
        id: "",
        accountNumber: textControllers["Account Number"]?.text ?? "",
        bankName: textControllers["Bank Name"]?.text ?? "",
        ifscNumber: textControllers["IFSC Code"]?.text ?? "",
        holderName: textControllers["Holder Name"]?.text ?? "",
        branchName: textControllers["Branch Name"]?.text ?? "",
        accountType: selectedAccountType.value,
        checkbook: '',
    checkbookOrPassbookImage: ''
    );
    await completeRegistration2(auth, data);
    auth.getUser();
  }

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false).getUser();

    selectedAccountType = AccountTypes.firstWhere(
            (element) =>
        element.value ==
            Provider.of<AuthProvider>(context, listen: false)
                .user!
                .bankDetails
                ?.accountType,
        orElse: () => AccountTypes[0]);
    passbookDBPath = Provider.of<AuthProvider>(context, listen: false).user?.bankDetails != null ? "${Constant.passbook_prefix_url + Provider.of<AuthProvider>(context, listen: false).user!.bankDetails!.checkbookOrPassbookImage ?? ""}" : "";

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, child) {
      return (auth.user!.bankDetails == null && BankEditMode == false)
          ? Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Looks like you have not uploaded your bank details.",
              style: TextStyle(fontSize: 18.sp),
            ),
            Divider(
              height: 40,
            ),
            GradientButton(text: "Upload Bank Details", onPressed: () =>  setState(() {
              BankEditMode = true;
            }),)
          ],
        ),
      )
          : Form(
        key: _bankFormKey,
        child: SingleChildScrollView(
          child: Column(
            children: [

              CustomText(context,
                  textControllers: textControllers,
                  editMode: BankEditMode,
                  title: Constants.holderNameKey,
                  content: auth.user!.bankDetails?.holderName ?? ""),
              CustomText(context,
                  editMode: BankEditMode,
                  textControllers: textControllers, title: Constants.accountNumberKey,
                  content: auth.user!.bankDetails?.accountNumber ?? "",
                  accountConfirm: true),
              if (BankEditMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ExpansionTile(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: UIColor.theme_color)),
                    collapsedShape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.grey)),
                    key: GlobalKey(),
                    title: Text(selectedAccountType.title),
                    children: AccountTypes.map((e) => ListTile(
                      onTap: () {
                        setState(() {
                          selectedAccountType = e;
                        });
                      },
                      title: Text(e.title),
                    )).toList(),
                  ),
                )
              else
                CustomText(context,
                    textControllers: textControllers,title: Constants.accountTypeKey,
                    content: AccountTypes.firstWhere(
                            (element) =>
                        element.value ==
                            auth.user!.bankDetails?.accountType,
                        orElse: () => AccountTypes[0]).title,
                    editMode: BankEditMode),
              CustomText(context,
                  textControllers: textControllers,  editMode: BankEditMode,
                  title: Constants.bankNameKey,
                  content: auth.user!.bankDetails?.bankName ?? ""),
              CustomText(context,
                  textControllers: textControllers,  editMode: BankEditMode,
                  title: Constants.branchNameKey,
                  content: auth.user!.bankDetails?.branchName ?? ""),
              CustomText(context,
                  textControllers: textControllers,  editMode: BankEditMode,
                  title: Constants.ifscCodeKey,
                  content: auth.user!.bankDetails?.ifscNumber ?? ""),
              if (BankEditMode)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                          child: passbookLocalPath == null && passbookDBPath == null
                              ? Text(
                              "Cancelled Checkbook / Passbook Front page")
                              : passbookLocalPath != null ? Container(
                              alignment: Alignment.centerLeft,
                              height: 80,
                              width: 80,
                              child: Image.file(File(passbookLocalPath!)))
                            : Container(
                            decoration: BoxDecoration( borderRadius: BorderRadius.circular(5), border: Border.all(color: UIColor.theme_color)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(imageUrl: passbookDBPath!,
                                fit: BoxFit.cover,

                                ),
                              ),
                          )

      ),
                      Expanded(flex: 1,child: SizedBox(),),
                      SizedBox(
                        width: 40,
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(side: BorderSide(color: UIColor.theme_color)),
                          onPressed: () async {
                            XFile? file = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (file != null) {
                              setState(() {
                                passbookLocalPath = file.path;
                              });
                            }
                          },
                          child: Text( style: TextStyle(color: UIColor.theme_color),
                              passbookDBPath == null ? "Choose" : "Change"))
                    ],
                  ),
                ),
              SizedBox(height: 20,),






              if (BankEditMode)
                isLoading
                    ? CircularProgressIndicator.adaptive(
                  backgroundColor: UIColor.theme_color,
                )
                    :   Container(
                  alignment: Alignment.center,
                  child: GradientButton(
                    text: "Save",
                    onPressed: () async{
                      if (_bankFormKey.currentState!.validate()) {
                        setState(() {
                          isLoading = !isLoading;
                        });
                       await setBankChanges(auth);
                        setState(() {
                          BankEditMode = false;
                          isLoading = !isLoading;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Successfully updated")));
                      }
                    },
                  ),
                ),

              if (!BankEditMode) Container(
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
                        BankEditMode = !BankEditMode;
                      });
                    }, child: Text("Edit Bank Details", style: TextStyle(color: UIColor.theme_color),)),
              ),

            ],
          ),
        ),
      );;
    });
  }
}
