import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/service.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/core/provider/ServiceProvider.dart';
import 'package:utsavlife/core/repo/order.dart';
import 'package:utsavlife/core/utils/UIColor.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/core/utils/validator.dart';
import 'package:utsavlife/routes/partialPaymentPage.dart';
import '../../routes/service/singleService.dart';
import '../models/order.dart';
import '../utils/util.dart';
import 'reject_popup.dart';
import 'package:html/parser.dart';

typedef Ontap = Function();

class CustomOrderItem extends StatefulWidget {
  Ontap? ontap;
  OrderModel order;
  bool showButtons;
  UpcomingOrderProvider? state;

  CustomOrderItem(
      {Key? key,
      required this.order,
      this.state,
      this.ontap,
      this.showButtons = true})
      : super(key: key);

  @override
  _CustomOrderItemState createState() => _CustomOrderItemState();
}

class _CustomOrderItemState extends State<CustomOrderItem> {
  late Color _statusColor;
  late String _statusText;
  late Color _statusTextColor = UIColor.toolbar_content_color;
  bool showReason = false, ShowReasonField = false;
  String selectedReason = "";

  @override
  void initState() {
    super.initState();
    choose_status();
    CustomLogger.debug(
        "vandor_order_status is ${widget.order.vendorOrderStatus}");
  }

  void choose_status() {
    switch (widget.order.vendorOrderStatus) {
      case VendorOrderStatus.rejected:
        _statusColor = Colors.red;
        _statusText = "Rejected";
        // _statusTextColor=Colors.red[100]!;
        break;
      case VendorOrderStatus.approved:
        _statusColor = UIColor.success_color;

        bool isCurrentDateWithinEndDate = false;
        if (widget.order.end_date != null) {
          DateTime endDate = DateTime.parse(widget.order.end_date!);
          isCurrentDateWithinEndDate = DateTime.now().isBefore(endDate);
        }
        _statusText = isCurrentDateWithinEndDate ? "Accepted" : "Delivered";
        //  _statusTextColor=UIColor.toolbar_content_color;

        break;
      default:
        _statusColor = UIColor.theme_color;
        _statusText = "Pending";
      //   _statusTextColor=UIColor.toolbar_content_color;
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
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Amount:"),
                            Text("Date: "),
                            Text("Location: "),
                            Text("Days"),
                            Text("Payment Status")
                          ],
                        ),
                        SizedBox(
                          width: 30.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("₹ ${widget.order.amount}"),
                            Text(formatDate(widget.order.date)),
                            Text(widget.order.address.isEmpty
                                ? "Not set"
                                : widget.order.address.length > 8
                                    ? widget.order.address.substring(0, 8)
                                    : widget.order.address),
                            Text(widget.order.days),
                            if (widget.order.paymentStatus ==
                                OrderPaymentStatus.partial)
                              FittedBox(
                                  child: Text(
                                "Partial Payment",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ))
                            else
                              FittedBox(
                                child: Text(
                                  "Payment Completed",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 10),
                                ),
                              )
                          ],
                        ),
                      ],
                    ),
                  )),
              Expanded(
                  child: Container(
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
                                                  order: widget.order))).then(
                                      (value) =>
                                          widget.state?.load_upcoming_orders());
                                },
                                child: Text(
                                  "Pay",
                                  style: TextStyle(color: Colors.white),
                                )),
                          if (widget.order.vendorOrderStatus ==
                                  VendorOrderStatus.rejected ||
                              widget.order.vendorOrderStatus ==
                                  VendorOrderStatus.pending)
                            OutlinedButton(
                                onPressed: () {
                                  approveOrder(context, widget.order.id);
                                },
                                child: Text(
                                  "Approve",
                                  style: TextStyle(color: Colors.green),
                                )),
                          if (widget.order.vendorOrderStatus ==
                                  VendorOrderStatus.approved ||
                              widget.order.vendorOrderStatus ==
                                  VendorOrderStatus.pending)
                            OutlinedButton(
                                /* onPressed: () {
                                    rejectOrder(context);
                                  },*/
                                onPressed: () {
                                  showRejectStatus(
                                    context,
                                    (reason) async {
                                      try {
                                        String message = await rejectOrder(
                                            Provider.of<AuthProvider>(context,
                                                listen: false),
                                            reason!,
                                            widget.order.id);
                                        widget.state?.load_upcoming_orders();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(message)));
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(e.toString())));
                                      }

                                      return;
                                    },
                                  );
                                },
                                child: Text("Reject",
                                    style: TextStyle(color: Colors.red))),
                        ],
                      )
                    : Container(),
              ))
            ],
          )),
    );
  }

  void approveOrder(BuildContext context, String id) async {
    try {
      await ChangeOrderStatus(Provider.of<AuthProvider>(context, listen: false),
          VendorOrderStatus.approved, id, "");
      widget.state?.load_upcoming_orders();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Order Approved")));
    } catch (e) {
      CustomLogger.error(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
    return Card(
      elevation: 2,
      shadowColor: UIColor.success_color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: BorderSide(color: UIColor.theme_color)),
      child: ListTile(
        title: RichText(text: TextSpan(
          children: [
           // TextSpan(text: "service name : ", style: TextStyle(color: UIColor.black_text_color, fontWeight: FontWeight.normal)),
            TextSpan(text: "${service.serviceName}", style: TextStyle(color: UIColor.black_text_color,fontSize: 18, fontWeight: FontWeight.bold))
          ]
        ),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5,),
            Text("Description : "),
            Text(_parseHtmlString(service.serviceDescription ?? "Not Set"), maxLines: 3,),
         /*   Container(
                constraints: BoxConstraints(
                  maxHeight: 105
                ),
                child: Html(data:service.serviceDescription!, shrinkWrap: false,)),*/
            SizedBox(height: 5,),
          Row(children: [
            Text("Status : "),
            Text(service.status ?? "Not set" , style: TextStyle(
                color: service.status==null ? UIColor.hint_text_color :  service.status!.startsWith("A") ? CupertinoColors.activeGreen : UIColor.error_color
            )),
          ],),

            Text("price : ₹${service.price}" ?? "Not set"),

          ],
        ),
        contentPadding: EdgeInsets.all(8),
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SingleService(
                    service: service,
                  ))).then((value) => state.getList());
        },
       /* trailing: Icon(Icons.more_vert),*/
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body?.text).documentElement!.text;

    return parsedString;
  }
}
