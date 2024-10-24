import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/reject_popup.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/core/utils/util.dart';
import 'package:utsavlife/routes/partialPaymentPage.dart';

import '../../core/utils/UIColor.dart';

class OrderDetailsPage extends StatefulWidget {
  String id;
  Function? onPop;
  bool readOnly;
  OrderModel order;

  OrderDetailsPage(
      {Key? key,
      required this.id,
      required this.readOnly,
      this.onPop,
      required this.order})
      : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String selectedReason = "";
  bool ShowReasonField = false;
  bool showReason = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return ListenableProvider(
      create: (_) => SingleOrderProvider(id: widget.id, auth: auth),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: UIColor.theme_color,
          elevation: 0,
          iconTheme: IconThemeData(color: UIColor.toolbar_content_color),
          title: Text("Order details",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: UIColor.toolbar_content_color)),
        ),
        body: Container(
          width: double.infinity,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    offset: Offset(-3, 3),
                    color: Colors.grey[200]!,
                    blurRadius: 1),
                BoxShadow(
                    offset: Offset(3, -3),
                    color: Colors.grey[200]!,
                    blurRadius: 1),
                BoxShadow(
                    offset: Offset(-3, 0),
                    color: Colors.grey[200]!,
                    blurRadius: 1),
                BoxShadow(
                    offset: Offset(0, -3),
                    color: Colors.grey[200]!,
                    blurRadius: 1),
              ]),
          child: Consumer<SingleOrderProvider>(
            builder: (context, singleOrderState, child) {
              if (singleOrderState.isLoading) {
                return Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              }
              if (singleOrderState.isLoading == false &&
                  singleOrderState.order == null) {
                return Container(
                  alignment: Alignment.center,
                  child: Text("Error fetching data.Please check logs"),
                );
              }
              return SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 6.h,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      "₹ ${singleOrderState.order!.amount}",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Text(
                      "General Information",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: DetailTile(
                              "Status",
                              singleOrderState.order!.vendorOrderStatus ==
                                      VendorOrderStatus.approved
                                  ? "Accepted"
                                  : singleOrderState.order!.vendorOrderStatus ==
                                          VendorOrderStatus.pending
                                      ? "Pending"
                                      : "Rejected")),
                      Expanded(
                          child: DetailTile(
                              "Event Name", singleOrderState.order!.category!)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: DetailTile(
                              "Category", singleOrderState.order!.category!)),
                      Expanded(
                          child: DetailTile(
                        "Category",
                        singleOrderState.order!.paymentStatus ==
                                OrderPaymentStatus.partial
                            ? "Partial Payment"
                            : "Payment Completed",
                      )),
                    ],
                  ),
                  DetailTile(
                      "Service Name", singleOrderState.order!.service_name!),
                  if (compareDate(
                      startDate: singleOrderState.order?.date ?? "",
                      dayCount: 7))
                    DetailTile("Address", singleOrderState.order!.address),
                  Row(
                    children: [
                      Expanded(
                          child: DetailTile("Order start date",
                              formatDate(singleOrderState.order!.date))),
                      Expanded(
                          child: DetailTile("Order end date",
                              formatDate(singleOrderState.order!.end_date!))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: DetailTile(
                              "Time", singleOrderState.order!.timing!)),
                      Expanded(
                          child:
                              DetailTile("Days", singleOrderState.order!.days)),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (singleOrderState.order!.admin_remarks != null &&
                      singleOrderState.order!.admin_remarks!.isNotEmpty)
                    Column(
                      children: [
                        DetailTile("Admin Remark",
                            singleOrderState.order!.admin_remarks!),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          child: Text(
                            "Customer Information",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: DetailTile(
                                    "Name",
                                    singleOrderState.order!.customer?.name ??
                                        "Not Set")),
                            if (singleOrderState.order?.vendorOrderStatus ==
                                VendorOrderStatus.approved)
                              Expanded(
                                  child: DetailTile(
                                      "email",
                                      singleOrderState.order!.customer?.email ??
                                          "Not Set")),
                          ],
                        ),
                        if (compareDate(
                            startDate: singleOrderState.order?.date ?? "",
                            dayCount: 7))
                          Row(
                            children: [
                              Expanded(
                                  child: DetailTile(
                                      "Phone",
                                      singleOrderState
                                              .order!.customer?.phoneNumber ??
                                          "Not Set")),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ));
            },
          ),
        ),
        bottomNavigationBar: (!widget.readOnly)
            ? Consumer<SingleOrderProvider>(
                builder: (context, singleOrderState, child) {
                if (singleOrderState.order == null) {
                  return Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator());
                }
                return BottomAppBar(
                  elevation: 0.5,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (singleOrderState.order?.vendorOrderStatus ==
                              VendorOrderStatus.approved &&
                          singleOrderState.order?.orderStatus ==
                              OrderStatus.onGoing)
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColorDark),
                            onPressed: () {
                              /* call the api for order delivered */
                              deliverOrder(context);
                            },
                            child: Text(
                              "Deliver",
                              style: TextStyle(color: Colors.white),
                            )),
                      if (singleOrderState.order?.paymentStatus ==
                          OrderPaymentStatus.partial)
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColorDark),
                            onPressed: () {
                              log((singleOrderState.order?.remaining_amount)
                                      .toString() ??
                                  "");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PartialPaymentPage(
                                          order: widget.order))).then((value) =>
                                  widget.onPop != null
                                      ? widget.onPop!()
                                      : null);
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => PartialPaymentPage(
                              //             order:
                              //                 singleOrderState.order!))).then(
                              //     (value) => widget.onPop != null
                              //         ? widget.onPop!()
                              //         : null);
                            },
                            child: Text(
                              "Pay",
                              style: TextStyle(color: Colors.white),
                            )),
                      if (singleOrderState.order?.vendorOrderStatus ==
                              VendorOrderStatus.rejected ||
                          singleOrderState.order?.vendorOrderStatus ==
                              VendorOrderStatus.pending)
                        BottomButton(
                            context: context,
                            onPressed: () => approveOrder(context),
                            text: "Accept",
                            primaryColor: Colors.green),
                      if ((singleOrderState.order?.vendorOrderStatus ==
                                  VendorOrderStatus.approved ||
                              singleOrderState.order?.vendorOrderStatus ==
                                  VendorOrderStatus.pending) &&
                          singleOrderState.order?.orderStatus !=
                              OrderStatus.delivered)
                        BottomButton(
                            context: context,
                            onPressed: () => showRejectStatus(
                                  context,
                                  (reason) => reject(
                                      context, reason!, singleOrderState),
                                ),
                            /*  */
                            text: "Reject",
                            primaryColor: Colors.red),
                    ],
                  ),
                );
              })
            : null,
      ),
    );
  }

  bool compareDate({required String startDate, required int dayCount}) {
    var strDate = DateTime.parse(startDate);
    var currentDate = DateTime.now();

    return strDate.difference(currentDate).inDays < dayCount;
  }

  void approveOrder(BuildContext context) async {
    try {
      await context
          .read<SingleOrderProvider>()
          .change_status(VendorOrderStatus.approved, "");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Order Accepted")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void deliverOrder(BuildContext context) async {
    try {
      await context
          .read<SingleOrderProvider>()
          .deliverOrder(OrderStatus.delivered);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Order Delivered")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget ReasonDialog(BuildContext context, List<String> rejectReasons) {
    return Container(
      height: 40.h,
      child: SingleChildScrollView(
        child: Column(children: [
          ...rejectReasons.map((e) => ListTile(
                leading: Radio(
                    value: e,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value!;
                        ShowReasonField = false;
                      });
                    }),
                title: Text(e),
              )),
          ListTile(
            title: Text("Other"),
            leading: Radio(
              autofocus: true,
              onChanged: (val) {
                setState(() {
                  selectedReason = "";
                  ShowReasonField = true;
                });
              },
              value: "Other",
              groupValue: selectedReason,
            ),
          ),
          if (ShowReasonField)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    selectedReason = text;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          SizedBox(
            height: 0,
          ),
          OutlinedButton(
              onPressed: () {
                try {
                  if (selectedReason == "") {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select a Reason")));
                  } else {
                    context.read<SingleOrderProvider>().change_status(
                        VendorOrderStatus.rejected, selectedReason);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Order Rejected")));
                    setState(() {
                      showReason = false;
                    });
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: Text("Submit"))
        ]),
      ),
    );
  }

  void rejectOrder(BuildContext context, List<String> rejectReasons) async {
    setState(() {
      showReason = true;
    });
  }

  Widget BottomButton(
      {required BuildContext context,
      Function()? onPressed,
      required String text,
      required Color primaryColor}) {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: BorderSide(width: 1, color: primaryColor)),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: primaryColor),
        ));
  }

  Widget DetailTile(String header, String body) {
    if (body == "") body = "Not set";
    return Container(
        constraints: BoxConstraints(maxHeight: 40.h),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: TextFormField(
          maxLines: null,
          decoration:
              InputDecoration(labelText: header, border: InputBorder.none),
          initialValue: body,
          readOnly: true,
        ));
  }
}
