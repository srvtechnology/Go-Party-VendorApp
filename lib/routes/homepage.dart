import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/components/filters.dart';
import 'package:utsavlife/core/components/listItems.dart';
import 'package:utsavlife/core/components/nav.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/core/provider/otpProvider.dart';
import 'package:utsavlife/routes/SingleOrder.dart';
import 'package:utsavlife/routes/imageViewPage.dart';
import 'package:utsavlife/routes/notifications.dart';

import 'mainpage.dart';

class Homepage extends StatefulWidget {
  static const routeName = "home";
  const Homepage({ Key? key }) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int index=0;
  final _drawerKey = GlobalKey();
  List<Widget> items = [
    const Orders(),
    const History(),
    const Profile(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>UpcomingOrderProvider(
            auth: Provider.of<AuthProvider>(context)
          )),
          ChangeNotifierProvider(create: (_)=>HistoryOrderProvider(
              auth: Provider.of<AuthProvider>(context)
          )),
        ],
        builder:(context,args)=> Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(onPressed: (){
                Provider.of<AuthProvider>(context,listen: false).logout();
                Navigator.pushReplacementNamed(context, MainPage.routeName);
              }, icon: Icon(Icons.logout)),
              IconButton(onPressed: (){
                Navigator.pushNamed(context, NotificationPage.routeName);
              }, icon:const Icon(Icons.notifications))
            ],
          ),
            body: items[index],
            bottomNavigationBar:CustomBottomNavBar(
              index: index,
              ontap: (i){
                setState(() {
                  if(i==2)Provider.of<AuthProvider>(context,listen: false).getUser();
                  index = i;
                });
              },
            ),
        ),
      ),
    );
  }
}


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool ProfileEditMode = false ;
  bool OfficeEditMode = false ;
  bool DocumentsEditMode = false ;
  Map<String,TextEditingController> textControllers = {
    "Email":new TextEditingController(),
    "Phone":new TextEditingController(),
    "Name":new TextEditingController(),
    "PanCard Number":new TextEditingController(),
    "Kyc Number":new TextEditingController(),
    "Kyc Type":new TextEditingController(),
    "PinCode":new TextEditingController(),
    "Area":new TextEditingController(),
    "Landmark":new TextEditingController(),
    "State":new TextEditingController(),
    "City":new TextEditingController(),
    "Calling Number":new TextEditingController(),
    "Gst Number":new TextEditingController(),
    "Office Number":new TextEditingController(),
    "Office PinCode":new TextEditingController(),
    "Office Area":new TextEditingController(),
    "Office Landmark":new TextEditingController(),
    "Office State":new TextEditingController(),
    "Office City":new TextEditingController(),
  } ;
  Map<String,String?> imgPath = {
    "Pan Card":null,
    "KYC":null,
    "GST":null,
    "Vendor":null
  };
  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    return Consumer<AuthProvider>(
      builder:(context,auth,child){
        return Container(
          height: double.infinity,
          width: double.infinity,
          padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: DefaultTabController(
              length: 3,
            child: Column(
              children: [
                _ProfileHeader(context,auth.user!.name,auth.user!.email),
                TabBar(tabs: [
                  Tab(child: Text("Personal",style: TextStyle(color: Colors.black),),),
                  Tab(child: Text("Office",style: TextStyle(color: Colors.black),),),
                  Tab(child: Text("Documents",style: TextStyle(color: Colors.black),),),
                ]),
                Expanded(child: Container(child: TabBarView(children: [
                  _PersonalInfo(auth),
                  _OfficeInfo(auth),
                  _DocumentInfo(auth),
                ],),))
                // Container(
                //   height: 100.h,
                //   child: SingleChildScrollView(
                //     child: TabBarView(
                //       children: [
                //         _PersonalInfo(auth),
                //         Text("tba"),
                //         Text("tba"),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            )
          ),
      );}
    );
  }
  Widget _OfficeInfo(AuthProvider auth){
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomRight,
            child: IconButton(onPressed: (){
              setState(() {
                OfficeEditMode = !OfficeEditMode;
              });
            }, icon: Icon(Icons.edit,color: OfficeEditMode?Theme.of(context).primaryColor:null),),
          ),
          _CustomText(context, editMode:OfficeEditMode,title: "Office PinCode",content: auth.user!.officeZip ?? "Not set"),
          _CustomText(context, editMode:OfficeEditMode,title: "Office Area",content: auth.user!.officeArea ?? "Not set"),
          _CustomText(context, editMode:OfficeEditMode,title: "Office Landmark",content: auth.user!.officeLandmark ?? "Not set"),
          _CustomText(context, editMode:OfficeEditMode,title: "Office State",content: auth.user!.officeState??"Not set"),
          _CustomText(context, editMode:OfficeEditMode,title: "Office City",content: auth.user!.officeCity??"Not set"),
          if(OfficeEditMode)
            Container(
              alignment: Alignment.center,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
                ),
                onPressed: () {
                  setOfficeChanges(auth);
                  auth.editOfficeDetails();
                  setState(() {
                    OfficeEditMode = false ;
                  });
                },
                child: Text("Save"),
              ),
            ),
        ],
      ),
    );

  }
  Widget _PersonalInfo(AuthProvider auth){
     return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomRight,
            child: IconButton(onPressed: (){
              setState(() {
                ProfileEditMode = !ProfileEditMode;
              });
            }, icon: Icon(Icons.edit,color: ProfileEditMode?Theme.of(context).primaryColor:null),),
          ),
          _CustomText(context, editMode:ProfileEditMode,title: "Email",content: auth.user!.email,canEdit: false),
          _CustomText(context, editMode:ProfileEditMode,title: "Phone",content: auth.user!.mobileno??"Not set",canEdit: false),
          _CustomText(context, editMode:ProfileEditMode,title: "Name",content: auth.user!.name),
          _CustomText(context, editMode:ProfileEditMode,title: "PanCard Number",content: auth.user!.panCardNumber??"Not set"),
          _CustomText(context, editMode:ProfileEditMode,title: "Kyc Number",content: auth.user!.kycNumber ??"Not set"),
          _CustomText(context, editMode:ProfileEditMode,title: "Kyc Type",content: auth.user!.kycType ?? "Not set"),
          _CustomText(context, editMode:ProfileEditMode,title: "PinCode",content: auth.user!.zip ?? "Not set"),
          _CustomText(context, editMode:ProfileEditMode,title: "Area",content: auth.user!.area ?? "Not set"),
          _CustomText(context, editMode:ProfileEditMode,title: "Landmark",content: auth.user!.landmark ?? "Not set"),
          _CustomText(context, editMode:ProfileEditMode,title: "State",content: auth.user!.state??"Not set"),
          _CustomText(context, editMode:ProfileEditMode,title: "City",content: auth.user!.city??"Not set"),
          if(ProfileEditMode)
            Container(
              alignment: Alignment.center,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
                ),
                onPressed: () {
                  setUserProfileChanges(auth);
                  auth.editProfile();
                  setState(() {
                    ProfileEditMode=false;
                  });
                },
                child: Text("Save"),
              ),
            ),
        ],
      ),
    );
  }
  Widget _DocumentInfo(AuthProvider auth){
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomRight,
            child: IconButton(onPressed: (){
              setState(() {
                DocumentsEditMode = !DocumentsEditMode;
              });
            }, icon: Icon(Icons.edit,color: DocumentsEditMode?Theme.of(context).primaryColor:null),),
          ),
          _CustomImage(context, imageUrl: auth.user!.panCardUrl??"", title: "Pan Card"),
          _CustomImage(context, imageUrl: auth.user!.kycUrl??"", title: "KYC"),
          _CustomImage(context, imageUrl: auth.user!.gstUrl??"", title: "GST"),
           _CustomImage(context, imageUrl: auth.user!.vendorUrl??"", title: "Vendor"),
          if(DocumentsEditMode)
            Container(
              alignment: Alignment.center,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
                ),
                onPressed: () async{
                      auth.editDocument(panPath: imgPath["Pan Card"],kycPath: imgPath["KYC"],vendorPath: imgPath["Vendor"],gstPath: imgPath["GST"]);
                      auth.getUser();
                      setState(() {
                        DocumentsEditMode = false;
                      });
                },
                child: Text("Save"),
              ),
            ),
        ],
      ),
    );
  }
  void setUserProfileChanges(AuthProvider auth){
    auth.user!.name =textControllers["Name"]!.text;
    auth.user!.panCardNumber = textControllers["PanCard Number"]!.text;
    auth.user!.kycNumber = textControllers["Kyc Number"]!.text;
    auth.user!.kycType = textControllers["Kyc Type"]!.text;
    auth.user!.zip = textControllers["PinCode"]!.text;
    auth.user!.area = textControllers["Area"]!.text;
    auth.user!.landmark = textControllers["Landmark"]!.text;
    auth.user!.state = textControllers["State"]!.text;
    auth.user!.city = textControllers["City"]!.text;
    auth.user!.callingNumber = textControllers["Calling Number"]!.text;
    auth.user!.gstNumber = textControllers["Gst Number"]!.text;
  }
  void setOfficeChanges(AuthProvider auth){
    auth.user!.officeNumber = textControllers["Office Number"]!.text ;
    auth.user!.officeZip = textControllers["Office PinCode"]!.text ;
    auth.user!.officeArea = textControllers["Office Area"]!.text ;
    auth.user!.officeLandmark = textControllers["Office Landmark"]!.text ;
    auth.user!.officeState = textControllers["Office State"]!.text ;
    auth.user!.officeCity=textControllers["Office City"]!.text ;
  }
  Widget _CustomImage(BuildContext context,{required String imageUrl,required String title}){
    return GestureDetector(
      onTap: (){
        Navigator.push(context,MaterialPageRoute(builder: (context)=>ImageViewer(imageUrl: imageUrl)));
      },
      child: Container(
        height: 10.h,
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        child: Row(
          children: [
            Expanded(child: CircleAvatar(radius: 30,backgroundImage: imageUrl.isEmpty?null:CachedNetworkImageProvider(imageUrl))),
            Expanded(flex: 5,child: Container(margin: EdgeInsets.symmetric(horizontal: 20),alignment: Alignment.centerLeft,child: Text(title)),),
            if(DocumentsEditMode)
            Expanded(flex: 2,child: Container(height:40,child: TextButton(onPressed: ()async{
              XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
              setState(() {
                imgPath["title"] = file?.path ;
              });
            },child: Text("Choose Image",style: TextStyle(fontSize: 12.sp,color: Colors.black),),style: TextButton.styleFrom(backgroundColor: Colors.grey[200]!),)),)
          ],
        ),
      ),
    );
  }
  Widget _CustomText(BuildContext context,{required String title,required String content,required bool editMode,bool canEdit=true}){
    textControllers[title]?.text = content ;
    return Container(
      margin:const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin:const EdgeInsets.symmetric(vertical: 5),child: Text(title,style:const TextStyle(fontWeight: FontWeight.bold),)),
          Container(margin:const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
               controller: textControllers[title],
                decoration: (editMode&&canEdit)?InputDecoration(border: const OutlineInputBorder()):InputDecoration(border: InputBorder.none),
                enabled: (editMode&&canEdit),
              )),
        ],
      ),
      );
  }
  Widget _ProfileHeader(BuildContext context,String name,String email){
    return Container(
      margin: const EdgeInsets.all(10),
        child: Row(
          children: [
             const Expanded(
               flex: 3,
               child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 40,
                child: CircleAvatar(backgroundColor: Colors.black,child: Icon(Icons.person),),
            ),
             ),
            Expanded(flex:6,child: Container(
              margin:const EdgeInsets.only(left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,style: Theme.of(context).textTheme.headlineSmall,),
                  Text(email,),
                ],
              ),
            ))
          ],
        ),
    );
  }
}



class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  void refresh(BuildContext context){
    context.read<HistoryOrderProvider>().load_history_orders();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        padding:const EdgeInsets.all(10),
        child: Column(children: [
          Expanded(child: Filter()),
          Expanded(
            child: Container(
              margin:const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
              child: Row(children:const [
                Expanded(flex:4,child: Text("Amount"),),
                Expanded(flex:4,child: Text("Date"),),
                Expanded(flex:4,child: Text("Location"),),
                Expanded(flex:4,child: Text("Days",textAlign: TextAlign.center,),),
                Expanded(child: Text(""),),
                    ],),
            ),
          ),
          Expanded(flex: 8,child: Consumer<HistoryOrderProvider>(
            builder: (context,orderState,child){
              if(orderState.isLoading){
                return Container(
                  alignment: Alignment.topCenter,
                  child:const CircularProgressIndicator(),
                );
              }
              else if(orderState.orders.isEmpty){
                return Container(
                  margin: EdgeInsets.all(10),
                  child: Text("No History"),
                );
              }
              return SingleChildScrollView(
                child: Column(
                    children: orderState.orders.map((e) => CustomOrderItem(order: e,ontap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleOrderPage(id:e.id,readOnly: true,))).then((value) => refresh(context));
                    },)).toList()),
              );
            },
          ))

        ]),
    );
  }
}

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  void refresh(BuildContext context){
    context.read<UpcomingOrderProvider>().load_upcoming_orders();
  }
  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding:const EdgeInsets.all(10),
      child: Column(children: [
        const Expanded(child: Filter()),
        Expanded(
          child: Container(
            margin:const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
            child: Row(children:const [
              Expanded(flex:4,child: Text("Amount"),),
              Expanded(flex:4,child: Text("Date"),),
              Expanded(flex:4,child: Text("Location"),),
              Expanded(flex:2,child: Text("Days",textAlign: TextAlign.center,),),
              Expanded(flex:3,child: Text(""),),
            ],),
          ),
        ),
        Expanded(flex: 8,child: Consumer<UpcomingOrderProvider>(
          builder: (context,orderState,child){
            if(orderState.isLoading){
              return Container(
                alignment: Alignment.topCenter,
                child:const CircularProgressIndicator(),
              );
            }
            else if(orderState.orders.isEmpty){
              return Container(
                margin: EdgeInsets.all(10),
                child: Text("No upcoming orders"),
              );
            }
            return SingleChildScrollView(
              child: Column(
                  children: orderState.orders.map((e) => CustomOrderItem(order: e,ontap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleOrderPage(id:e.id,readOnly: false,))).then((value) => refresh(context));
                  },)).toList()),
            );
          },
        ))
      ]),
    );
  }
}