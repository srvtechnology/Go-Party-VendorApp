import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/wallet.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/walletProvider.dart';
import 'package:utsavlife/core/repo/wallet.dart';
import 'package:utsavlife/core/utils/UIColor.dart';
import 'package:utsavlife/core/utils/logger.dart';

class WalletPage extends StatefulWidget {
  static const routeName = "/wallet";

  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final TextEditingController _withdrawAmount = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _withdraw(BuildContext context, double withdrawAmount,
      WalletProvider walletProvider) {
    _withdrawAmount.text="";
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(25), topLeft: Radius.circular(25))),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child:  Padding(
              padding: const EdgeInsets.all(25.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Available to withdraw",
                      style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "₹ $withdrawAmount",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        keyboardType:
                        TextInputType.numberWithOptions(signed: false),
                        controller: _withdrawAmount,
                        decoration: InputDecoration(
                            labelText: "Enter Amount",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15))),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if(value==null || value.isEmpty){
                            return "Please enter the amount";
                          }
                          if(double.parse(value)>walletProvider.walletData.availableToWithdraw){
                            return "The amount should be either ${walletProvider.walletData.availableToWithdraw} or less than ${walletProvider.walletData.availableToWithdraw}.";
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Some error occurred, Please try again.")));
                              if (_formKey.currentState!.validate()) {
                                try {
                                  String? status = await withdrawAmountFromWallet(
                                      context.read<AuthProvider>(),
                                      _withdrawAmount.text);

                                  if (status != null) {
                                    walletProvider
                                        .getDetails(context.read<AuthProvider>());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(status)));
                                  } else
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Some error occurred, Please try again.")));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Some error occurred, Please try again.")));
                                }

                                Navigator.pop(context);
                              }
                            },
                            child: Text("Withdraw",style: TextStyle(color: UIColor.toolbar_content_color),),
                        style: ElevatedButton.styleFrom(backgroundColor: UIColor.theme_color),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (_) => WalletProvider(context.read<AuthProvider>()),
      child: Consumer<WalletProvider>(builder: (context, state, child) {
        if (state.isLoading) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: UIColor.theme_color,
            elevation: 0,
            iconTheme: IconThemeData(color: UIColor.toolbar_content_color),
            title: Text("Your Money",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: UIColor.toolbar_content_color)),
          ),
          body: Stack(
            children: [
              Container(
                height: 20.h,
                decoration: BoxDecoration(
                    color: UIColor.theme_color,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100))),
              ),
              Container(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 20.h,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[300]!,
                                offset: Offset(0, 1),
                                spreadRadius: 1,
                                blurRadius: 1)
                          ]),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Available to withdraw: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              Text(
                                state.walletData.availableToWithdraw.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pending Amount: ",
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                state.walletData.totalAmount.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _withdraw(context,
                                  state.walletData.availableToWithdraw, state);
                            },
                            child: Text(
                              "Withdraw",
                              style: TextStyle(
                                  color: UIColor.toolbar_content_color),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: UIColor.theme_color),
                          )
                        ],
                      ),
                    ),
                    Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: Text(
                          "Latest Transactions",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        )),
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[300]!,
                                offset: Offset(0, 1),
                                spreadRadius: 1,
                                blurRadius: 1)
                          ]),
                      child: state.transactionData.isNotEmpty
                          ? SingleChildScrollView(
                              child: Column(
                                  children: state.transactionData
                                      .map((e) => TransactionTile(
                                            transaction: e,
                                          ))
                                      .toList()),
                            )
                          : Text(
                              "Looks like you do not have any Transactions !",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.w500),
                            ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  TransactionTile({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[300]!,
                offset: Offset(0, 1),
                spreadRadius: 1,
                blurRadius: 1)
          ]),
      child: Row(
        children: [
          Expanded(
              child: CircleAvatar(
            backgroundColor: Colors.redAccent,
            radius: 15,
            child: Text("D"),
          )),
          Expanded(
              flex: 2,
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.transactionType),
                  Text(
                    transaction.transactionDate.toString().substring(0, 10),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ))),
          Expanded(
              flex: 4,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                      child: Text(" ${transaction.amount.toString()}"))))
        ],
      ),
    );
  }
}
