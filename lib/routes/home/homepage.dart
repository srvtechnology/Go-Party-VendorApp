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
import 'package:utsavlife/routes/SingleOrder.dart';
import 'package:utsavlife/routes/imageViewPage.dart';
import 'package:utsavlife/routes/notifications.dart';
import 'package:utsavlife/routes/pdfView.dart';
import 'package:utsavlife/routes/profile/profileScreen.dart';
import 'package:utsavlife/routes/servicelist.dart';
import 'package:utsavlife/routes/settingsPage.dart';
import 'package:utsavlife/routes/singleServiceAdd.dart';
import 'package:utsavlife/routes/wallet.dart';
import '../../core/models/dropdown.dart';
import '../../core/models/order.dart';
import '../../core/utils/scaling.dart';
import '../mainpage.dart';
import 'dart:io';

import 'Order.dart';

class Homepage extends StatefulWidget {
  int startingIndex;
  static const routeName = "home";
  Homepage({Key? key, this.startingIndex = 0}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState(startingIndex: startingIndex);
}

class _HomepageState extends State<Homepage> {
  int startingIndex;
  GlobalKey _drawer = GlobalKey();
  GlobalKey _addServices = GlobalKey();
  GlobalKey _serviceList = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  _HomepageState({required this.startingIndex});
  int index = 0;
  final _drawerKey = GlobalKey();
  List<Widget> items = [
    const Orders(),
    const History(),
    const Profilescreen(),
  ];
  List<String> itemName =["Orders","History","Profile"];



  @override
  void initState() {
    super.initState();
    index = startingIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => UpcomingOrderProvider(
                  auth: Provider.of<AuthProvider>(context))),
          ChangeNotifierProvider(
              create: (_) => HistoryOrderProvider(
                  auth: Provider.of<AuthProvider>(context))),
        ],
        builder: (context, args) => Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  DrawerHeader(
                    child: SizedBox(
                      height: 20.h,
                      width: 40.w,
                      child: Image.asset("assets/images/logo/logo.png"),
                    ),
                  ),
                  Showcase(
                    key: _addServices,
                    description: "Click here to add new service",
                    child: ListTile(
                        title: Text("Add services"),
                        leading: Icon(Icons.cleaning_services),
                        onTap: () {
                          Navigator.popAndPushNamed(
                              context, AddServiceRoute.routeName);
                        }),
                  ),
                  Showcase(
                    key: _serviceList,
                    description: "Click here to view the services you added",
                    child: ListTile(
                        title: Text("Services List"),
                        leading: Icon(Icons.list_alt),
                        onTap: () {
                          Navigator.popAndPushNamed(
                              context, serviceListRoute.routeName);
                        }),
                  ),
                  /*        ListTile(
                      title: Text("Notifications"),
                      leading: Icon(Icons.notifications_active),
                      onTap: () {}),*/
                  ListTile(
                      title: Text("Settings"),
                      leading: Icon(Icons.settings),
                      onTap: () {
                        Navigator.popAndPushNamed(context, SettingsPage.routeName);
                      }),
                  ListTile(
                      title: Text("Your Money"),
                      leading: Icon(Icons.wallet),
                      onTap: () {
                        Navigator.popAndPushNamed(context, WalletPage.routeName);
                      }),
                  ListTile(
                      title: Text("Logout"),
                      leading: Icon(Icons.logout),
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .logout();
                        Navigator.pushReplacementNamed(
                            context, MainPage.routeName);
                      }),
                ],
              ),
            ),
          ),
          appBar: AppToolbar(toolbarTitle: "${itemName[index]}", onPressed: () {
            try {
              ShowCaseWidget.of(context)
                  .startShowCase([_addServices, _serviceList]);
            } catch (e) {}
            _scaffoldKey.currentState!.openDrawer();
          },
          leadingIcon: Icon(Icons.menu),
          ),
          body: items[index],
          bottomNavigationBar: CustomBottomNavBar(
            index: index,
            ontap: (i) {
              setState(() {
                index = i;
              });
            },
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

// Utitilty function
class CardItem {
  String title;
  IconData icon;
  Function onTap;
  CardItem({required this.title, required this.icon, required this.onTap});
}

class _DashboardState extends State<Dashboard> {
  List<CardItem> cards = [
    CardItem(
        title: "Add services",
        icon: Icons.cleaning_services,
        onTap: (context) {
          Navigator.pushNamed(context, AddServiceRoute.routeName);
        }),
    CardItem(
        title: "Services List",
        icon: Icons.list_alt,
        onTap: (context) {
          Navigator.pushNamed(context, serviceListRoute.routeName);
        }),
    CardItem(
        title: "Notifications", icon: Icons.notifications_active, onTap: () {}),
    CardItem(
        title: "Profile",
        icon: Icons.person,
        onTap: (context) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Homepage(
                        startingIndex: 3,
                      )));
        }),
    CardItem(
        title: "Logout",
        icon: Icons.logout,
        onTap: (context) {
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.pushReplacementNamed(context, MainPage.routeName);
        }),
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, state, child) {
      return Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: GridView.builder(
            itemCount: cards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, int index) {
              return card(
                  title: cards[index].title,
                  icon: cards[index].icon,
                  onTap: () {
                    cards[index].onTap(context);
                  });
            }),
      );
    });
  }

  Widget card(
      {required String title,
      required IconData icon,
      required Function onTap}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
          height: 15.h,
          margin: EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                height: 10.h,
                width: 65.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.grey[400]!,
                          blurRadius: 2),
                      BoxShadow(
                          offset: Offset(1, 0),
                          color: Colors.grey[400]!,
                          blurRadius: 2)
                    ]),
                margin: const EdgeInsets.all(5.0),
                child: Icon(
                  icon,
                  size: 30.sp,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                      )))
            ],
          )),
    );
  }
}


class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String searchitem = "";
  VendorOrderStatus? orderStatus;
  GlobalKey _history = GlobalKey();
  @override
  void initState() {
    super.initState();
    /* TODO commented */
    /*    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([_history])); */
  }

  void refresh(BuildContext context) {
    context.read<HistoryOrderProvider>().load_history_orders();
    setState(() {
      searchitem = "";
      orderStatus == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (context, isScrolled) {
        return [
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            snap: true,
            expandedHeight: 70,
            elevation: 1,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Filter(
              onsearch: (String searchItem) {
                setState(() {
                  searchitem = searchItem;
                });
                //  context.watch<HistoryOrderProvider>().load_history_orders();
                Provider.of<HistoryOrderProvider>(context, listen: false)
                    .load_history_orders();
              },
              onstatusSelect: (VendorOrderStatus? status) {
                setState(() {
                  orderStatus = status;
                });
                //  context.watch<HistoryOrderProvider>().load_history_orders();
                Provider.of<HistoryOrderProvider>(context, listen: false)
                    .load_history_orders();
              },
            ),
            centerTitle: true,
          )
        ];
      },
      body: Showcase(
        key: _history,
        description:
            "This is the section where you can see your previous orders.",
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Expanded(
                flex: 16,
                child: Consumer<HistoryOrderProvider>(
                  builder: (context, orderState, child) {
                    if (orderState.isLoading) {
                      return Container(
                        alignment: Alignment.topCenter,
                        child: const CircularProgressIndicator(),
                      );
                    } else if (orderState.orders.isEmpty) {
                      return Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.all(10),
                        child: Text("No History"),
                      );
                    }
                    return SingleChildScrollView(
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
                                    showButtons: false,
                                    order: e,
                                    ontap: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SingleOrderPage(
                                                        id: e.id,
                                                        readOnly: true,
                                                      )))
                                          .then((value) => refresh(context));
                                    },
                                  ))
                              .toList()),
                    );
                  },
                ))
          ]),
        ),
      ),
    );
  }
}


