import 'package:cached_network_image/cached_network_image.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dio/dio.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:utsavlife/core/components/appToolbar.dart';
import 'package:utsavlife/core/components/filters.dart';
import 'package:utsavlife/core/components/listItems.dart';
import 'package:utsavlife/core/components/nav.dart';
import 'package:utsavlife/core/models/user.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/core/repo/auth.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:utsavlife/routes/home/OrderDetails.dart';
import 'package:utsavlife/routes/imageViewPage.dart';
import 'package:utsavlife/routes/notifications.dart';
import 'package:utsavlife/routes/pdfView.dart';
import 'package:utsavlife/routes/profile/profileScreen.dart';
import 'package:utsavlife/routes/service/servicelist.dart';
import 'package:utsavlife/routes/settingsPage.dart';
import 'package:utsavlife/routes/service/singleServiceAdd.dart';
import 'package:utsavlife/routes/wallet.dart';
import '../../core/models/dropdown.dart';
import '../../core/models/order.dart';
import '../../core/utils/scaling.dart';
import '../mainpage.dart';
import 'dart:io';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  String searchitem = "";
  VendorOrderStatus? orderStatus;
  GlobalKey _order = GlobalKey();
  void refresh(BuildContext context) {
    context.read<UpcomingOrderProvider>().load_upcoming_orders();
    setState(() {
      searchitem = "";
      orderStatus = null;
    });
  }

  @override
  void initState() {
    super.initState();
    /* TODO commented this line */
    /*  WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context).startShowCase([_order])
    ); */
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (context, isScrolled) => [
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floating: true,
          snap: true,
          title: Filter2(
            onsearch: (String searchItem) {
              setState(
                () {
                  searchitem = searchItem;
                  context.read<UpcomingOrderProvider>().load_upcoming_orders();
                },
              );
            },
            onstatusSelect: (VendorOrderStatus? status) {
              setState(() {
                orderStatus = status;
                context.read<UpcomingOrderProvider>().load_upcoming_orders();
              });
            },
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        )
      ],
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Expanded(
              flex: 16,
              child: Consumer<UpcomingOrderProvider>(
                builder: (context, orderState, child) {
                  if (orderState.isLoading) {
                    return Container(
                      alignment: Alignment.topCenter,
                      child: const CircularProgressIndicator(),
                    );
                  } else if (orderState.orders.isEmpty) {
                    return Showcase(
                      key: _order,
                      description:
                          "This is the upcoming order section. The Pending and Upcoming orders will be shown here",
                      child: Container(
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        margin: EdgeInsets.all(10),
                        child: Text("No upcoming orders"),
                      ),
                    );
                  }
                  return Showcase(
                    key: _order,
                    description:
                        "This is the upcoming order section. The Pending and Upcoming orders will be shown here",
                    child: SingleChildScrollView(
                      child: Column(
                          children: orderState.orders
                              .where((element) =>
                                  (element.amount.contains(searchitem) ||
                                      element.service_name!
                                          .toLowerCase()
                                          .contains(searchitem.toLowerCase())))
                              .where((element) {
                                if (orderStatus == null) return true;
                                return element.vendorOrderStatus == orderStatus;
                              })
                              .map((e) => CustomOrderItem(
                                    state: orderState,
                                    order: e,
                                    ontap: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailsPage(
                                                        order: e,
                                                        onPop: () {
                                                          orderState
                                                              .load_upcoming_orders();
                                                        },
                                                        id: e.id,
                                                        readOnly: false,
                                                      )))
                                          .then((value) => refresh(context));
                                    },
                                  ))
                              .toList()),
                    ),
                  );
                },
              ))
        ]),
      ),
    );
  }
}
