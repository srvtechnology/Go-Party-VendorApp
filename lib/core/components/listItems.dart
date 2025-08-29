import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/service.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/core/provider/ServiceProvider.dart';
import 'package:utsavlife/core/repo/order.dart';
import 'package:utsavlife/routes/partialPaymentPage.dart';
import '../../routes/singleService.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';

typedef Ontap = Function();

class CustomOrderItem extends StatefulWidget {
  Ontap? ontap;
  OrderModel order;
  bool showButtons;
  UpcomingOrderProvider? state;
  BuildContext context;

  CustomOrderItem(
      {Key? key,
      required this.order,
      this.state,
      this.ontap,
      required this.context,
      this.showButtons = true})
      : super(key: key);

  @override
  _CustomOrderItemState createState() => _CustomOrderItemState();
}

class _CustomOrderItemState extends State<CustomOrderItem> {
  late Color _statusColor;
  late String _statusText;
  late Color _statusTextColor;
  bool showReason = false, ShowReasonField = false;
  String selectedReason = "";

  @override
  void initState() {
    super.initState();
    choose_status();
  }

  void choose_status() {
    switch (widget.order.vendorOrderStatus) {
      case VendorOrderStatus.rejected:
        _statusColor = Colors.red[700]!;
        _statusText = "Rejected";
        _statusTextColor = Colors.red[100]!;
        break;
      case VendorOrderStatus.approved:
        _statusColor = Colors.greenAccent;
        _statusText = "Accepted";
        _statusTextColor = Colors.green[900]!;

        break;
      default:
        _statusColor = Colors.yellowAccent;
        _statusText = "Pending";
        _statusTextColor = Colors.yellow[900]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.ontap,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 3),
                    color: Colors.grey[400]!,
                    blurRadius: 4)
              ]),
          width: 100.w,
          height: 25.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        widget.order.service_name ?? "",
                        style: TextStyle(color: _statusTextColor),
                      ),
                    ),
                    Container(
                        child: Text(
                      _statusText,
                      style: TextStyle(color: _statusTextColor),
                    )),
                  ],
                ),
              )),
              Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Order ID:"),
                              Text("Amount:"),
                              Text("Date: "),
                              Text("Location: "),
                              Text("Days"),
                              Text("Payment Status")
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.order.orderId}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("₹ ${addGstToAmount(widget.order.amount)}"),
                              Text(formatDate(widget.order.date)),
                              Text(
                                widget.order.address.isEmpty
                                    ? "Not set"
                                    : widget.order.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(widget.order.days),
                              Text(
                                widget.order.paymentStatus ==
                                        OrderPaymentStatus.partial
                                    ? "Partial Payment"
                                    : "Payment Completed",
                                style: TextStyle(
                                  color: widget.order.paymentStatus ==
                                          OrderPaymentStatus.partial
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                  child: ListenableProvider(
                create: (_) =>
                    ReasonProvider(auth: Provider.of<AuthProvider>(context)),
                child:
                    Consumer<ReasonProvider>(builder: (context, state, child) {
                  if (showReason == true) {
                    return ReasonDialog(context, state.reasons ?? []);
                  }
                  return Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: widget.showButtons
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (widget.order.paymentStatus ==
                                  OrderPaymentStatus.partial)
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColorDark),
                                    onPressed: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PartialPaymentPage(
                                                          order: widget.order)))
                                          .then((value) => widget.state
                                              ?.load_upcoming_orders());
                                    },
                                    child: Text(
                                      "Pay",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              if (canMarkAsDelivered(widget.order.end_date.toString(),  widget.order.paymentStatus.toString()))
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () async {
                                    final provider = widget.state;
                                    if (provider == null) return;

                                    // Capture safe context
                                    final currentContext = context;

                                    final result = await provider
                                        .deliverMyOrder(widget.order.id);

                                    if (mounted) return;

                                    ScaffoldMessenger.of(widget.context)
                                        .showSnackBar(
                                      SnackBar(
                                          content: Text(result["message"] ??
                                              "Something went wrong")),
                                    );
                                    if (result["message"] == "Order has been delivered successfully") {
                                      provider.load_upcoming_orders();
                                    }
                                  },
                                  child: const Text(
                                    "Delivered",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              if (widget.order.vendorOrderStatus ==
                                      VendorOrderStatus.rejected ||
                                  widget.order.vendorOrderStatus ==
                                      VendorOrderStatus.pending)
                                OutlinedButton(
                                    onPressed: () {
                                      approveOrder(context, widget.order.id);
                                    },
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(color: Colors.green),
                                    )),
                              if (widget.order.vendorOrderStatus ==
                                      VendorOrderStatus.approved ||
                                  widget.order.vendorOrderStatus ==
                                      VendorOrderStatus.pending)
                                !isOldDate(widget.order.date)
                                    ? OutlinedButton(
                                        onPressed: () {
                                          rejectOrder(context);
                                        },
                                        child: Text("Reject",
                                            style:
                                                TextStyle(color: Colors.red)))
                                    : SizedBox(),
                            ],
                          )
                        : Container(),
                  );
                }),
              ))
            ],
          )),
    );
  }

  bool isToday(String orderDate) {
    try {
      final parsedDate = DateTime.parse(orderDate);
      final now = DateTime.now();

      return parsedDate.year == now.year &&
          parsedDate.month == now.month &&
          parsedDate.day == now.day;
    } catch (e) {
      return false; // Invalid date format
    }
  }

  bool canMarkAsDelivered(String endDate, String paymentStatus) {
    try {
      final parsedDate = DateTime.parse(endDate);
      final now = DateTime.now();

      // Check if end date is today or before today.
      final isTodayOrPast = !parsedDate.isAfter(DateTime(now.year, now.month, now.day));

      final isPaymentComplete = paymentStatus.toLowerCase() != "partial payment";

      return isTodayOrPast && isPaymentComplete;
    } catch (e) {
      print("Date parsing error: $e");
      return false;
    }
  }

  bool isOldDate(String orderDate) {
    try {
      final parsedDate = DateTime.parse(orderDate);
      final now = DateTime.now();
      return parsedDate.isBefore(DateTime(now.year, now.month, now.day));
    } catch (e) {
      return false; // If date parsing fails, assume it's not old
    }
  }

  double addGstToAmount(dynamic amount, {double gstPercent = 18}) {
    // Ensure amount is parsed correctly
    double baseAmount = double.tryParse(amount.toString()) ?? 0.0;
    double gstAmount = baseAmount * gstPercent / 100;
    return baseAmount + gstAmount;
  }

  void approveOrder(BuildContext context, String id) async {
    try {
      ChangeOrderStatus(Provider.of<AuthProvider>(context, listen: false),
          VendorOrderStatus.approved, id, "");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Order Approved")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String formatDate(String date) {
    try {
      // Normalize input to ensure month/day are 2 digits
      List<String> parts = date.split('-');
      if (parts.length != 3) return date; // fallback

      String year = parts[0];
      String month = parts[1].padLeft(2, '0');
      String day = parts[2].padLeft(2, '0');

      String normalizedDate = '$year-$month-$day';
      DateTime parsedDate = DateTime.parse(normalizedDate);

      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      print("❌ Date parse error: $e");
      return date; // fallback if parsing fails
    }
  }


  void rejectOrder(BuildContext context) async {
    setState(() {
      showReason = true;
    });
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
}

class CustomServiceItem extends StatelessWidget {
  int index;
  ServiceModel service;
  ServiceListProvider state;

  CustomServiceItem(
      {Key? key,
      required this.index,
      required this.service,
      required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SingleService(
                      service: service,
                    ))).then((value) => state.getList());
      },
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3),
                      color: Colors.grey[400]!,
                      blurRadius: 4)
                ]),
            width: 100.w,
            height: 20.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "${(index + 1)}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        service.address?.substring(
                                0, min(service.address!.length, 10)) ??
                            "",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                )),
                Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 20.w, child: Text("Name:")),
                              SizedBox(
                                width: 10.w,
                              ),
                              SizedBox(
                                  width: 30.w,
                                  child:
                                      Text(service.serviceName ?? "Not Set")),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 20.w, child: Text("Price:")),
                              SizedBox(
                                width: 10.w,
                              ),
                              SizedBox(
                                  width: 30.w,
                                  child: Text(service.price ?? "Not Set")),
                            ],
                          ),
                        ],
                      ),
                    )),
              ],
            )),
      ),
    );
  }
}
