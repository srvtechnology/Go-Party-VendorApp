import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/appToolbar.dart';
import 'package:utsavlife/core/components/gradientButton.dart';
import 'package:utsavlife/core/models/dropdown.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/order.dart';
import 'package:utsavlife/core/features/ccavenues/models/enc_val_res.dart';
import 'package:utsavlife/core/features/ccavenues/patmentWebview.dart';

import '../core/utils/UIColor.dart';

const EdgeInsets textInputPadding =
    EdgeInsets.symmetric(vertical: 8, horizontal: 0);

class PartialPaymentPage extends StatefulWidget {
  final OrderModel order;

  const PartialPaymentPage({Key? key, required this.order}) : super(key: key);

  @override
  State<PartialPaymentPage> createState() => _PartialPaymentPageState();
}

class _PartialPaymentPageState extends State<PartialPaymentPage> {
  TextEditingController _controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int selectedPaymentMode = 0;

  List<DropDownField> paymentModes = [
    DropDownField(title: "Online", value: "O"),
    DropDownField(title: "Cash", value: "C"),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.text = widget.order.amount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppToolbar(
        toolbarTitle: "Partial Payment",
        onPressed: Navigator.of(context).pop,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 0.5),
                        color: Colors.grey[400]!,
                        blurRadius: 1,
                        spreadRadius: 1),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Details",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "₹ ${widget.order.amount}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: DetailTile(
                                  "Status",
                                  widget.order.vendorOrderStatus ==
                                          VendorOrderStatus.approved
                                      ? "Accepted"
                                      : widget.order.vendorOrderStatus ==
                                              VendorOrderStatus.pending
                                          ? "Pending"
                                          : "Rejected")),
                          Expanded(
                              child: DetailTile(
                                  "Event Name", widget.order.category!)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: DetailTile(
                                  "Category", widget.order.category!)),
                          Expanded(
                              child: DetailTile(
                            "Payment Status",
                            widget.order.paymentStatus ==
                                    OrderPaymentStatus.partial
                                ? "Partial Payment"
                                : "Payment Completed",
                          )),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 0.5),
                        color: Colors.grey[400]!,
                        blurRadius: 1,
                        spreadRadius: 1),
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Remaining Amount ",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: textInputPadding,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.currency_rupee,
                            color: UIColor.prefix_icon_tint),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        label: Text(
                          "Due Amount",
                          style: TextStyle(color: UIColor.hint_text_color),
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
                      child: Text(
                        widget.order.remaining_amount.toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Container(
                    padding: textInputPadding,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.money, color: UIColor.prefix_icon_tint),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        label: Text(
                          "Payment Type",
                          style: TextStyle(color: UIColor.hint_text_color),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.arrow_drop_down),
                          color: UIColor.prefix_icon_tint,
                          onPressed: null,
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
                      child: DropdownButton<DropDownField>(
                        value: paymentModes[selectedPaymentMode],
                        items: paymentModes
                            .map((DropDownField item) =>
                                DropdownMenuItem<DropDownField>(
                                    child: Text(item.title), value: item))
                            .toList(),
                        onChanged: (DropDownField? value) {
                          setState(() {
                            selectedPaymentMode = paymentModes.indexOf(value!);
                          });
                        },
                        underline: SizedBox.shrink(),
                        icon: SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GradientButton(
                    buttonInsideMaterialBox: true,
                    text: _isLoading
                        ? "Processing..."
                        : (paymentModes[selectedPaymentMode].value == "C"
                            ? "Confirm"
                            : "Pay"),
                    onPressed: () {
                      if (_isLoading) return;
                      _payAmount();
                    },
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void payViaOnline() async {
    try {
      log(widget.order.id, name: "Order Id");
      log(widget.order.remaining_amount.toString(), name: "Amount");
      final res = await payPartialAmount(context.read<AuthProvider>(),
          widget.order.id, (widget.order.remaining_amount).toString());
      log(res.toString(), name: "response");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            generateOrderValue: GenerateOrderValue(
              orderId: int.parse(res['fullPayObject']['order_id'].toString()),
              accessCode: res['fullPayObject']['access_code'],
              redirectUrl: res['fullPayObject']['redirect_url'],
              cancelUrl: res['fullPayObject']['cancel_url'],
              encVal: res['fullPayObject']['enc_val'],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred, please try later")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void payViaCash() async {
    // if (formKey.currentState!.validate()) {
    try {
      await payPartialAmountCash(
          context.read<AuthProvider>(), widget.order.id, _controller.text);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Amount Paid")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occured, please try later")));
      //Navigator.pop(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    //
  }

  void _payAmount() async {
    setState(() {
      _isLoading = true;
    });

    if (paymentModes[selectedPaymentMode].value == "O") {
      // Online payment
      payViaOnline();
    } else if (paymentModes[selectedPaymentMode].value == "C") {
      // Cash payment
      payViaCash();
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid payment mode selected")),
      );
    }
  }

  Widget DetailTile(String header, String body) {
    if (body == "") body = "Not set";
    return Container(
        constraints: BoxConstraints(maxHeight: 40.h),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextFormField(
          maxLines: null,
          decoration:
              InputDecoration(labelText: header, border: InputBorder.none),
          initialValue: body,
          readOnly: true,
        ));
  }
}
