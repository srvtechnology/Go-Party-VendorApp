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
import 'package:utsavlife/routes/servicelist.dart';
import 'package:utsavlife/routes/settingsPage.dart';
import 'package:utsavlife/routes/singleServiceAdd.dart';
import 'package:utsavlife/routes/wallet.dart';
import '../core/models/dropdown.dart';
import '../core/models/order.dart';
import '../core/utils/scaling.dart';
import 'mainpage.dart';
import 'dart:io';
class Homepage extends StatefulWidget {
  int startingIndex;
  static const routeName = "home";
  Homepage({ Key? key,this.startingIndex=0}) : super(key: key);

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
  int index=0;
  final _drawerKey = GlobalKey();
  List<Widget> items = [
    const Orders(),
    const History(),
    const Profile(),
  ];
  @override
  void initState() {
    super.initState();
    index=startingIndex;
  }
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
          key: _scaffoldKey,
          drawer: Drawer(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 20,),
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
                    child: ListTile(title: Text("Add services"), leading:Icon( Icons.cleaning_services), onTap: (){
                      Navigator.pushNamed(context, AddServiceRoute.routeName);
                    }),
                  ),
                  Showcase(
                    key: _serviceList,
                    description: "Click here to view the services you added",
                    child: ListTile(title:Text( "Services List"), leading:Icon( Icons.list_alt), onTap: (){
                      Navigator.pushNamed(context, serviceListRoute.routeName);
                    }),
                  ),
                  ListTile(title:Text( "Notifications"), leading:Icon( Icons.notifications_active), onTap: (){}),
                  ListTile(title:Text( "Settings"), leading:Icon( Icons.settings), onTap: (){
                    Navigator.pushNamed(context, SettingsPage.routeName);
                  }),
                  ListTile(title:Text( "Wallet"), leading:Icon( Icons.wallet), onTap: (){
                    Navigator.pushNamed(context, WalletPage.routeName);
                  }),
                  ListTile(title:Text( "Logout"), leading:Icon( Icons.logout), onTap: (){
                    Provider.of<AuthProvider>(context,listen: false).logout();
                    Navigator.pushReplacementNamed(context, MainPage.routeName);
                  }),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: SizedBox(child: Image.asset("assets/images/logo/logo.png",),height: 25,),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              color: Theme.of(context).primaryColorDark,
              onPressed: (){
                try{
                  ShowCaseWidget.of(context).startShowCase([_addServices,_serviceList]);
                }catch(e){}
                _scaffoldKey.currentState!.openDrawer();
              },
              icon: Icon(Icons.menu),
            ),
            actions: [
              IconButton(onPressed: (){
                Provider.of<AuthProvider>(context,listen: false).logout();
                Navigator.pushReplacementNamed(context, MainPage.routeName);
              }, icon: Icon(Icons.logout,color: Theme.of(context).primaryColorDark,)),
              IconButton(onPressed: (){
                Navigator.pushNamed(context, NotificationPage.routeName);
              }, icon: Icon(Icons.notifications,color: Theme.of(context).primaryColorDark))
            ],
          ),
            body: items[index],
            bottomNavigationBar:CustomBottomNavBar(
              index: index,
              ontap: (i){
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
class CardItem
{
  String title;
  IconData icon;
  Function onTap;
  CardItem({required this.title,required this.icon,required this.onTap});
}

class _DashboardState extends State<Dashboard> {
  List<CardItem> cards = [
    CardItem(title: "Add services", icon: Icons.cleaning_services, onTap: (context){
      Navigator.pushNamed(context, AddServiceRoute.routeName);
    }),
    CardItem(title: "Services List", icon: Icons.list_alt, onTap: (context){
      Navigator.pushNamed(context, serviceListRoute.routeName);
    }),
    CardItem(title: "Notifications", icon: Icons.notifications_active, onTap: (){}),
    CardItem(title: "Profile", icon: Icons.person, onTap: (context){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Homepage(startingIndex: 3,)));
    }),
    CardItem(title: "Logout", icon: Icons.logout, onTap: (context){
      Provider.of<AuthProvider>(context,listen: false).logout();
      Navigator.pushReplacementNamed(context, MainPage.routeName);
    }),
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder:(context,state,child){
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
            ), itemBuilder:(context,int index){
              return card(title: cards[index].title, icon: cards[index].icon, onTap:(){
                cards[index].onTap(context);
              });
            }),
          );
        }
    );
  }
  Widget card({required String title,required IconData icon,required Function onTap}){
    return GestureDetector(
      onTap: (){
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
                        offset: Offset(0,1),
                        color: Colors.grey[400]!,
                        blurRadius: 2
                    ),
                    BoxShadow(
                        offset: Offset(1,0),
                        color: Colors.grey[400]!,
                        blurRadius: 2
                    )
                  ]
              ),
              margin: const EdgeInsets.all(5.0),
              child: Icon(icon,size: 30.sp,color: Theme.of(context).primaryColorDark,),
            ),
            Expanded(
                child:Container(
                    margin: EdgeInsets.only(bottom: 10),
                    alignment: Alignment.bottomCenter,
                    child: Text(title,textAlign: TextAlign.center,)))
          ],
        )
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
  String? profileImageLocal;
  bool BankEditMode = false ;
  late Country selectedOfficeCountry;
  late Country selectedCountry;

  String? passbookPath;
  String passbookUrl = "storage/app/public/vandor/checkbookOrPassbookImage";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _docFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _bankFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> _officeFormKey = GlobalKey<FormState>();
  GlobalKey _profile = GlobalKey();
  List<DropDownField> kyctypes = [
    DropDownField(title: "Aadhar",value: "AD"),
    DropDownField(title: "Voter Id",value: "VO"),
    DropDownField(title: "Passport",value: "PA"),
    DropDownField(title: "Driving License",value: "DL"),
    DropDownField(title: "Other Govt. Id",value: "OT"),
  ];
  List<DropDownField> AccountTypes = [
    DropDownField(title: "Current Account",value: "current"),
    DropDownField(title: "Savings Account",value: "saving"),
    DropDownField(title: "Salary Account",value: "salary"),
    DropDownField(title: "Fixed Deposit Account",value: "fixed"),
    DropDownField(title: "Recurring Deposit Account",value: "recurring"),
    DropDownField(title: "NRI Account",value: "nri"),
  ];
  bool profileImageloading= false;
  late DropDownField selectedAccountType;
  Map<String,TextEditingController> textControllers = {
    "Email":new TextEditingController(),
    "Phone":new TextEditingController(),
    "Name":new TextEditingController(),
    "PanCard Number":new TextEditingController(),
    "Kyc Number":new TextEditingController(),
    "Kyc Type":new TextEditingController(),
    "PinCode":new TextEditingController(),
    "Address":new TextEditingController(),
    "Area":new TextEditingController(),
    "Landmark":new TextEditingController(),
    "State":new TextEditingController(),
    "City":new TextEditingController(),
    "House Number":new TextEditingController(),
    "Calling Number":new TextEditingController(),
    "GST Number":new TextEditingController(),
    "Office Number":new TextEditingController(),
    "Office Phone":new TextEditingController(),
    "Office PinCode":new TextEditingController(),
    "Office Area":new TextEditingController(),
    "Office Landmark":new TextEditingController(),
    "Office State":new TextEditingController(),
    "Office City":new TextEditingController(),
    "Office Country":new TextEditingController(),
    "Holder Name":new TextEditingController(),
    "Bank Name":new TextEditingController(),
    "Branch Name":new TextEditingController(),
    "IFSC Code":new TextEditingController(),
    "Account Number":new TextEditingController(),
    "Account Type":new TextEditingController(),
  } ;
  Map<String,String?> imgPath = {
    "Pan Card":null,
    "KYC":null,
    "GST":null,
    "Vendor":null
  };
  late DropDownField selectedKyc;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context).startShowCase([_profile])
    );
    Provider.of<AuthProvider>(context,listen: false).getUser();
    selectedOfficeCountry = Provider.of<AuthProvider>(context,listen: false).user?.officeCountry??Country(id:"101", name:"India");
    selectedCountry = Country(id:"101", name:"India");
    selectedKyc = kyctypes.firstWhere((element) => element.value == Provider.of<AuthProvider>(context,listen: false).user!.kycType,orElse: ()=>kyctypes[0]);
    selectedAccountType = AccountTypes.firstWhere((element) => element.value == Provider.of<AuthProvider>(context,listen: false).user!.bankDetails?.accountType,orElse: ()=>AccountTypes[0]);
    selectedCountry = Provider.of<AuthProvider>(context,listen: false).user?.country??Country(id:"101", name:"India");
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder:(context,auth,child){
        return Container(
           height: double.infinity,
           width: double.infinity,
           margin:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
           padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
           child: DefaultTabController(
                length: 4,
              child: Column(
                    children: [
               _ProfileHeader(context,auth,auth.user!.name,auth.user!.email,auth.user!.vendorUrl),
               SizedBox(height: 10,),
               Expanded(child: Showcase(
                 key: _profile,
                 description: "This is the profile section. You can edit / view your details",
                 child: Container(
                   margin: EdgeInsets.only(top: 10),
                   decoration: BoxDecoration(
                       color: Colors.white,
                       boxShadow: [
                         BoxShadow(
                             offset: Offset(3,3),
                             color: Colors.grey[300]!,
                           blurRadius: 2
                         ),
                         BoxShadow(
                             offset: Offset(-3,-3),
                             color: Colors.grey[300]!,
                           blurRadius: 2
                         ),
                       ],
                       borderRadius: BorderRadius.circular(15)
                   ),
                   child: Column(
                     children: [
                       Expanded(
                         child:  Container(
                           margin: EdgeInsets.symmetric(horizontal: 10,vertical: 16.sp),
                           child: TabBar(
                             unselectedLabelColor: Colors.black,
                               labelColor: Colors.white,
                               indicator: BoxDecoration(
                                   borderRadius: BorderRadius.circular(20),
                                   color: Theme.of(context).primaryColorDark
                               ),
                               tabs: [
                                 Tab(child: Text("Personal",style: TextStyle(fontSize: 14.sp),),),
                                 Tab(child: Text("Office",style: TextStyle(fontSize: 15.sp),),),
                                 Tab(child: Text("Bank",style: TextStyle(fontSize: 15.sp),),),
                                 Tab(child: Text("Doc",style: TextStyle(fontSize: 15.sp),),),
                               ]),
                         ),
                       ),
                       Expanded(
                         flex: 5,
                         child: TabBarView(children: [
                         _PersonalInfo(auth),
                         _OfficeInfo(auth),
                         SingleChildScrollView(child: _BankDetailsInfo(auth)),
                         _DocumentInfo(auth),
                 ],),
                       ),
                     ],
                   ),),
               ))

                    ],
                  )
            ),
      );}
    );
  }
  Widget _OfficeInfo(AuthProvider auth){
    return Form(
      key: _officeFormKey,
      child: SingleChildScrollView(
        physics: OfficeEditMode?ClampingScrollPhysics():NeverScrollableScrollPhysics(),
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
            _CustomText(context, editMode:OfficeEditMode,title: "Phone Number",controllerKey: "Office Phone",content: auth.user!.officePhone ?? "",validatePhone:true),
            if(OfficeEditMode)
              Column(
                children: [
                  _CustomText(context, editMode:OfficeEditMode,title: "Flat / House / Building Number",controllerKey: "Office Number",content: auth.user!.officeNumber ?? ""),
                  _CustomText(context, editMode:OfficeEditMode,title: "Street/Sector/Village/Area",controllerKey: "Office Area",content: auth.user!.officeArea ?? ""),
                  _CustomText(context, editMode:OfficeEditMode,title: "Landmark",controllerKey: "Office Landmark",content: auth.user!.officeLandmark ?? ""),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: CSCPicker(
                      currentCity: auth.user!.officeCity??"",
                      currentState: auth.user!.officeState??"",
                      currentCountry: auth.user!.officeCountry?.name??"",
                      defaultCountry: CscCountry.India,
                      showStates: true,
                      showCities: true,
                      onCountryChanged: (country){
                        setState(() {
                          textControllers["Office Country"]!.text=country??"";
                        });
                      },
                      onStateChanged: (state){
                        setState(() {
                          textControllers["Office State"]!.text=state??"";
                        });
                      },
                      onCityChanged: (city){
                        setState(() {
                          textControllers["Office City"]!.text=city??"";
                        });
                      },
                    ),
                  ),
                  _CustomText(context, editMode:OfficeEditMode,title: "PinCode",controllerKey: "Office PinCode",content: auth.user!.officeZip ?? "",isPin:true),
                 ],
              )
              else
                _CustomText(context, title: "Address", content: "${auth.user!.officeNumber}, ${auth.user!.officeLandmark}, ${auth.user!.officeArea}, ${auth.user!.officeCity}, ${auth.user!.officeZip}, ${auth.user!.officeState}, ${auth.user!.officeCountry?.name??""}", editMode: OfficeEditMode),
              if(OfficeEditMode)
              Container(
                alignment: Alignment.center,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
                  ),
                  onPressed: () {
                    if(_officeFormKey.currentState!.validate()){
                      if(textControllers["Office State"]!.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select state")));
                        return;
                      }
                      if(textControllers["Office City"]!.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select city")));
                        return;
                      }
                      setOfficeChanges(auth);
                      auth.editOfficeDetails();
                      setState(() {
                        OfficeEditMode = false ;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully updated")));
                    }
                    },
                  child: Text("Save"),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _BankDetailsInfo(AuthProvider auth){
    return  (auth.user!.bankDetails == null && BankEditMode==false)?
    Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Text("Looks like you have not uploaded your bank details.",style: TextStyle(fontSize: 18.sp),),
          Divider(height: 40,),
          OutlinedButton(onPressed: (){
            setState(() {
              BankEditMode = true;
            });
          }, child: Text("Upload"))
        ],
      ),
    )
    :
      Form(
        key: _bankFormKey,
        child: Column(
          children: [
            Container(
              alignment: Alignment.bottomRight,
              child: IconButton(onPressed: (){
                setState(() {
                  BankEditMode = !BankEditMode;
                });
              }, icon: Icon(Icons.edit,color: BankEditMode?Theme.of(context).primaryColor:null),),
             ),
            _CustomText(context, editMode:BankEditMode,title: "Holder Name",content: auth.user!.bankDetails?.holderName ?? ""),
            _CustomText(context, editMode:BankEditMode,title: "Account Number",content: auth.user!.bankDetails?.accountNumber ?? "",accountConfirm: true),
            if(BankEditMode)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          label:Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: Text("Account Type"),
                          ),
                            contentPadding: EdgeInsets.symmetric(horizontal:0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                  )
                    ),
                        child: ExpansionTile(
                          trailing:Text(""),
                          key: GlobalKey(),
                          title: Text(selectedAccountType.title),
                          children: AccountTypes.map((e) => ListTile(
                            onTap: (){
                              setState(() {
                                selectedAccountType = e ;
                              });
                            },
                            title: Text(e.title),
                          )).toList(),
                        ),
                      )
                    ),
                  ],
                ),
              )
            else _CustomText(context, title: "Account Type", content: AccountTypes.firstWhere((element) => element.value==auth.user!.bankDetails?.accountType,orElse:()=> AccountTypes[0]).title, editMode: BankEditMode),
            _CustomText(context, editMode:BankEditMode,title: "Bank Name",content: auth.user!.bankDetails?.bankName ?? ""),
            _CustomText(context, editMode:BankEditMode,title: "Branch Name",content: auth.user!.bankDetails?.branchName ?? ""),
            _CustomText(context, editMode:BankEditMode,title: "IFSC Code",content: auth.user!.bankDetails?.ifscNumber ?? ""),
            if(BankEditMode)
              Container(
              padding: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
              child: Row(
                children: [
                  Expanded(child: passbookPath==null?Text("Cancelled Checkbook / Passbook Front page"):Container(alignment: Alignment.centerLeft,height: 80,width: 80,child:Image.file(File(passbookPath!)))),
                  SizedBox(width: 40,),
                  OutlinedButton(onPressed: ()async{
                    XFile? file =  await ImagePicker().pickImage(source: ImageSource.gallery);
                    if(file!=null){
                      setState(() {
                        passbookPath = file.path;
                      });
                    }
                  }, child: Text(passbookPath==null?"Choose":"Change"))
                ],
              ),
            ),
            if(BankEditMode)
              Container(
                alignment: Alignment.center,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
                  ),
                  onPressed: () {
                    if(_bankFormKey.currentState!.validate()){
                      setBankChanges(auth);
                      setState(() {
                        BankEditMode = false ;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully updated")));
                    }
                   },
                  child: Text("Save"),
                ),
              ),
          ],
    ),
      );

  }
  Future<void> setBankChanges(AuthProvider auth)async{
    Map<String,dynamic> data ={
      "bank_name":textControllers["Bank Name"]?.text,
      "acc_no":textControllers["Account Number"]?.text,
      "ifsc_no":textControllers["IFSC Code"]?.text,
      "holder_name":textControllers["Holder Name"]?.text,
      "branch_name":textControllers["Branch Name"]?.text,
      "acc_type":selectedAccountType.value,
    };
    if(passbookPath!=null){
      data["img1"]=await MultipartFile.fromFile(passbookPath!);
    }
    auth.user?.bankDetails = BankDetails(id: "",

        accountNumber:textControllers["Account Number"]?.text??"",
        bankName: textControllers["Bank Name"]?.text??"",
        ifscNumber: textControllers["IFSC Code"]?.text??"",
        holderName: textControllers["Holder Name"]?.text??"",
        branchName: textControllers["Branch Name"]?.text??"",
        accountType: selectedAccountType.value, checkbook: ''
    );
    await completeRegistration2(auth, data);
    auth.getUser();
  }
  Widget _PersonalInfo(AuthProvider auth){
     return SingleChildScrollView(
      child: Form(
        key: _formKey,
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
            _CustomText(context, editMode:ProfileEditMode,title: "Name",content: auth.user!.name??"Not yet",canEdit: false),
            _CustomText(context, editMode:ProfileEditMode,title: "Phone Number",controllerKey: "Phone",content: auth.user!.mobileno??"",validatePhone: true),
            _CustomText(context, editMode:ProfileEditMode,title: "Email",content: auth.user!.email,canEdit: false),
            _CustomText(context, editMode:ProfileEditMode,controllerKey: "PanCard Number",title: "Pan Number",content: auth.user!.panCardNumber??"",capitals:true),
            _CustomText(context, editMode:ProfileEditMode,title: "GST Number",controllerKey: "GST Number",content: auth.user!.gstNumber ?? "",capitals: true),
            if(ProfileEditMode)
              Container(
              margin: EdgeInsets.symmetric(horizontal: 45),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Kyc Type"),
                  DropdownButton(
                    value: selectedKyc,
                    items: kyctypes.map((e)=>DropdownMenuItem(child: Text(e.title),value: e,)).toList(),
                    onChanged: (_){
                      setState(() {
                        textControllers["Kyc Type"]?.text = _!.value ;
                        selectedKyc = _! ;
                      });
                    },
                  ),
                ],
              ),
            )
            else  _CustomText(context,editMode: ProfileEditMode, title: "Kyc Type", content:kyctypes.firstWhere((element) => element.value == auth.user!.kycType,orElse: ()=>kyctypes[0]).title??"",canEdit: false),
            _CustomText(context, editMode:ProfileEditMode,controllerKey: "Kyc Number",title: "${selectedKyc.title} Number",content: auth.user!.kycNumber ??""),
            if(ProfileEditMode)
              Column(
                children: [
                  _CustomText(context, editMode:ProfileEditMode,controllerKey: "House Number",title: "Flat / House / Building Number",content: auth.user!.area ?? ""),
                  _CustomText(context, editMode:ProfileEditMode,controllerKey: "Area",title: "Street/Sector/Village/Area",content: auth.user!.area ?? ""),
                  _CustomText(context, editMode:ProfileEditMode,title: "Landmark",content: auth.user!.landmark ?? ""),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: CSCPicker(
                      defaultCountry: CscCountry.India,
                      currentState: auth.user!.state,
                      currentCity: auth.user!.city,
                      onCountryChanged: (country){

                      },
                      onStateChanged: (state){
                          textControllers["State"]!.text=state??"";
                      },
                      onCityChanged: (city){
                          textControllers["City"]!.text=city??"";
                      },
                    )
                  ),
                  _CustomText(context, editMode:ProfileEditMode,title: "PinCode",content: auth.user!.zip ?? "",isPin:true),
                ],
              )
            else
              _CustomText(context, title: "Address", content: "${auth.user!.houseNumber}, ${auth.user!.landmark??"hu"}, ${auth.user!.area??""}, ${auth.user!.city??""}, ${auth.user!.zip ?? ""}, ${auth.user!.state??""},${auth.user!.country?.name??"India"}", editMode: ProfileEditMode),
            if(ProfileEditMode)
              Container(
                alignment: Alignment.center,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
                  ),
                  onPressed: () {
                    if(_formKey.currentState!.validate()){
                      if(textControllers["State"]!.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select state")));
                        return;
                      }
                      if(textControllers["City"]!.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select city")));
                        return;
                      }
                      setUserProfileChanges(auth);
                      auth.editProfile();
                      setState(() {
                        ProfileEditMode=false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully updated")));
                    }
                  },
                  child: Text("Save"),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _DocumentInfo(AuthProvider auth){
    return SingleChildScrollView(
      child: Form(
        key: _docFormKey,
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
            _CustomImage(context, imageUrl: auth.user!.gstUrl??"", title: "GST"),
            if(DocumentsEditMode)
              Container(
                alignment: Alignment.center,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
                  ),
                  onPressed: () async{
                        if(_docFormKey.currentState!.validate()) {
                          auth.editDocument(panPath: imgPath["Pan Card"],
                              kycPath: imgPath["KYC"],
                              vendorPath: imgPath["Vendor"],
                              gstPath: imgPath["GST"]);
                          auth.getUser();
                          setState(() {
                            DocumentsEditMode = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Successfully updated")));
                        }
                  },
                  child: Text("Save"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void setUserProfileChanges(AuthProvider auth){
    auth.user!.name =textControllers["Name"]!.text;
    auth.user!.panCardNumber = textControllers["PanCard Number"]!.text;
    auth.user!.mobileno  = textControllers["Phone"]!.text;
    auth.user!.kycNumber = textControllers["Kyc Number"]!.text;
    auth.user!.kycType = selectedKyc.value;
    auth.user!.zip = textControllers["PinCode"]!.text;
    auth.user!.area = textControllers["Area"]!.text;
    auth.user!.landmark = textControllers["Landmark"]!.text;
    auth.user!.state = textControllers["State"]!.text;
    auth.user!.city = textControllers["City"]!.text;
    auth.user!.houseNumber = textControllers["House Number"]!.text;
    auth.user!.country = selectedCountry ;
    auth.user!.callingNumber = textControllers["Calling Number"]!.text;
    auth.user!.gstNumber = textControllers["GST Number"]!.text;
  }

  void setOfficeChanges(AuthProvider auth){
    CustomLogger.debug(textControllers["Office State"]!.text);
    auth.user!.officePhone = textControllers["Office Phone"]!.text ;
    auth.user!.officeNumber = textControllers["Office Number"]!.text ;
    auth.user!.officeZip = textControllers["Office PinCode"]!.text ;
    auth.user!.officeArea = textControllers["Office Area"]!.text ;
    auth.user!.officeLandmark = textControllers["Office Landmark"]!.text ;
    auth.user!.officeState = textControllers["Office State"]!.text ;
    auth.user!.officeCity=textControllers["Office City"]!.text ;
    auth.user!.officeCountry=selectedOfficeCountry;
  }

  Widget _CustomImage(BuildContext context,{required String imageUrl,required String title}){
    return GestureDetector(
      onTap: (){
        if(imageUrl.endsWith("pdf")){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>pdfViewer(pdfUrl: imageUrl)));
        }
        else {
          Navigator.push(context,MaterialPageRoute(builder: (context)=>ImageViewer(imageUrl: imageUrl)));
        }
      },
      child: Container(
        height: 10.h,
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        child: Row(
          children: [
            if(imgPath[title]!=null)
          Expanded(
              child: Container(
              child: Image.file(File(imgPath[title]!))))
        else
            Expanded(
              child: Container(
              child: (imageUrl.isEmpty && imageUrl.endsWith("pdf")==false)?Text(""):CachedNetworkImage(
          errorWidget: (context,url,args){
            return Icon(Icons.account_box,size: 50,);
          },
          placeholder: (context,url)=>Container(alignment: Alignment.center,child: const CircularProgressIndicator()),
          imageUrl: imageUrl,)),
            ),
            Expanded(flex: 5,child: Container(margin: EdgeInsets.symmetric(horizontal: 20),alignment: Alignment.centerLeft,child: Text(title)),),
            if(DocumentsEditMode)
            Expanded(flex: 2,child: Container(height:40,child: TextButton(onPressed: ()async{
              if(imageUrl.endsWith("pdf")){
                FilePickerResult? file = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ["pdf"]);
                setState(() {
                  imgPath[title] = file?.files.single.path ;
                });
              }
              else{
                XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                setState(() {
                  imgPath[title] = file?.path ;
                });
              }

            },child: Text("Choose file",style: TextStyle(fontSize: 12.sp,color: Colors.black),),style: TextButton.styleFrom(backgroundColor: Colors.grey[200]!),)),)
          ],
        ),
      ),
    );
  }

  Widget _CustomText(BuildContext context,{required String title,String? controllerKey,required String content,required bool editMode,bool canEdit=true,bool capitals = false,bool accountConfirm=false,validatePhone=false,bool isCountry=false,bool personal=false,bool isPin=false}){
    if(controllerKey==null){
      controllerKey = title;
    }
    if(content.isEmpty){
      content = "Not Set";
    }

    if(validatePhone && editMode){
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: IntlPhoneField(
          initialValue: content,
          showCountryFlag: false,
          decoration: InputDecoration(
              labelText: title, labelStyle:TextStyle(color: Colors.black,fontSize: 16.sp),
              hintText: "Not set",
              border: const OutlineInputBorder(
              ),
          enabled: (editMode&&canEdit),
          ),
          validator: (text){
            if(text==null || text.completeNumber.isEmpty){
              return "Required field";
            }
            if(text.completeNumber.length<12 || text.completeNumber.length>15){
              return "Please enter a valid number";
            }
          },
          onChanged: (number){
            textControllers[controllerKey]?.text = number.completeNumber;
          },
        ),
      );

    }
    textControllers[controllerKey]?.text = content ;
    return Container(
      margin:const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child:(isCountry&&editMode)?Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Country",style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  child: DropdownSearch<Country>(
                    selectedItem: personal?selectedCountry:selectedOfficeCountry,
                    onChanged: (country){
                      if(personal){
                        setState(() {
                          selectedCountry = country! ;
                        });
                      }else{
                        setState(() {
                          selectedOfficeCountry = country! ;
                        });
                      }

                    },
                    items: DefaultCountries.map((e) => Country(id: e["id"].toString(), name: e["name"])).toList(),
                  ),
                ),

              ],
            ),
            SizedBox(height: 20,),

          ],
        ),
      )
          :
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin:const EdgeInsets.symmetric(vertical: 10),
              child: editMode?TextFormField(
                keyboardType: validatePhone||accountConfirm||isPin?TextInputType.phone:TextInputType.text,
                validator: (text){
                  if(text==null || text.isEmpty) return "Required";
                  if(accountConfirm){
                    if(text.length<12 ||text.length>20)return "Enter Valid Account Number";
                  }
                  if(validatePhone){
                    if(text.length<10 || text.length>13)return "Enter valid Number";
                  }
                  if(isPin){
                    if (text.length!=6){
                      return "Please enter a 6 digit valid pincode";
                    }
                  }
                },
                textCapitalization: capitals?TextCapitalization.characters:TextCapitalization.none,
               controller: textControllers[controllerKey],
                decoration:InputDecoration(
                    labelText: title, labelStyle:TextStyle(color: Colors.black,fontSize: 16.sp),
                    hintText: "Not set",
                    border: const OutlineInputBorder()), enabled: (editMode&&canEdit),
              ):Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,style: TextStyle(color: Colors.black,fontSize: 16.sp,fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  Text(content,style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                ],
              )),
        ],
      ),
      );
  }

  Widget _ProfileHeader(BuildContext context,AuthProvider auth,String name,String email,String? profileImage){
    return GestureDetector(
      onTap: ()async{
        await showDialog(context: context, builder:(context){
          return StatefulBuilder(
            builder: (context,setState) {
              return SimpleDialog(
                children: [
                  if(profileImageLocal!=null)
                    Container(
                      height: 25.h,
                      child: CircleAvatar(backgroundColor: Colors.black,backgroundImage: FileImage(File(profileImageLocal!)),),
                    )
                  else Container(
                    height: 25.h,
                    child: CircleAvatar(backgroundColor: Colors.black,backgroundImage: CachedNetworkImageProvider(profileImage??"",errorListener: ()=>Icon(Icons.account_box))),
                  ),
                  SizedBox(height: 20,),
                  if (profileImageloading)
                    Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: OutlinedButton(onPressed: ()async{
                            XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if(file!=null){
                              setState(() {
                                profileImageLocal=file.path;
                              });
                            }
                          }, child: Text("Select New Image",style: TextStyle(fontSize: 14.sp),)),
                        ),
                      ),
                      if(profileImageLocal!=null)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: OutlinedButton(onPressed: ()async{
                              if(profileImageLocal!=null)
                              {
                                setState((){
                                  profileImageloading=true;
                                });
                                await auth.editProfileImage(profilePath: profileImageLocal!);
                                await auth.getUser();
                                Navigator.pop(context);
                              }

                            }, child: Text("Save")),
                          ),
                        ),
                    ],
                  )
                ],
              );
            }
          );
        });
        setState(() {
          profileImageLocal=null;
          profileImageloading=false;
        });
      },
      child: Container(
        alignment: Alignment.center,
        height: 12.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0,2),
              blurRadius: 2
            ),
          ]
        ),
        margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Expanded(
                 flex: 3,
                 child: CircleAvatar(
                   radius: 30,
                   backgroundColor: Colors.black,
                     child: Stack(
                       children: [
                         Positioned.fill(
                             bottom: 5.h,
                             left: 5.h,
                             child: CircleAvatar(
                                 backgroundColor: Theme.of(context).primaryColor,child: Icon(Icons.edit_rounded,color: Colors.white,size: 10,))),
                       ],
                     ),backgroundImage: profileImage!=null?CachedNetworkImageProvider(profileImage!):null,),
               ),
              Expanded(flex:6,child: Container(
                margin:const EdgeInsets.only(left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name,style: Theme.of(context).textTheme.headlineSmall,),
                    Text(email,style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,textScaleFactor: ScaleSize.textScaleFactor(context),),
                  ],
                ),
              )),
              Expanded(
                flex: 2,
                  child: Container(
                child: Icon(Icons.verified,color: Theme.of(context).primaryColor,),
              ))
            ],
          ),
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
  String searchitem = "";
  VendorOrderStatus? orderStatus;
  GlobalKey _history = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context).startShowCase([_history])
    );
  }
  void refresh(BuildContext context){
    context.read<HistoryOrderProvider>().load_history_orders();
    setState(() {
      searchitem = "";
      orderStatus==null ;
    });
  }
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (context,isScrolled){
        return [
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            snap: true,
            expandedHeight: 70,
            elevation: 1,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Filter(onsearch: (String searchItem) {
              setState(() {
                searchitem = searchItem ;
              });
              context.watch<HistoryOrderProvider>().load_history_orders();
            },onstatusSelect: (VendorOrderStatus? status) {
              setState(() {
                orderStatus=status;
              });
              context.watch<HistoryOrderProvider>().load_history_orders();
            },),
            centerTitle: true,
          )
        ];
      },
      body: Showcase(
        key: _history,
        description: "This is the section where you can see your previous orders.",
        child: Container(
            height: double.infinity,
            width: double.infinity,
            padding:const EdgeInsets.all(10),
            child: Column(children: [
              Expanded(flex: 16,child: Consumer<HistoryOrderProvider>(
                builder: (context,orderState,child){
                  if(orderState.isLoading){
                    return Container(
                      alignment: Alignment.topCenter,
                      child:const CircularProgressIndicator(),
                    );
                  }
                  else if(orderState.orders.isEmpty){
                    return Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.all(10),
                      child: Text("No History"),
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                        children:orderState.orders.where((element) => (element.amount.contains(searchitem)|| element.service_name!.toLowerCase().contains(searchitem.toLowerCase())))
                            .where((element) {
                          if(orderStatus==null)return true;
                          return element.vendorOrderStatus == orderStatus ;
                        }).map((e) => CustomOrderItem(showButtons: false,order: e,ontap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleOrderPage(id:e.id,readOnly: true,))).then((value) => refresh(context));
                        },)).toList()),
                  );
                },
              ))

            ]),
        ),
      ),
    );
  }
}

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  String searchitem = "";
  VendorOrderStatus? orderStatus;
  GlobalKey _order = GlobalKey();
  void refresh(BuildContext context){
    context.read<UpcomingOrderProvider>().load_upcoming_orders();
    setState(() {
    searchitem="";
    orderStatus=null;
    });
  }
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context).startShowCase([_order])
    );
  }
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (context,isScrolled)=> [
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floating: true,
          snap: true,
          title: Filter2(onsearch: (String searchItem) {
            setState(() {
              searchitem = searchItem;
              context.read<UpcomingOrderProvider>().load_upcoming_orders();
            },);
          }, onstatusSelect: (VendorOrderStatus? status) {
            setState(() {
              orderStatus=status;
              context.read<UpcomingOrderProvider>().load_upcoming_orders();
            });
          },),
          centerTitle: true,
          automaticallyImplyLeading: false,
        )
      ],
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding:const EdgeInsets.all(10),
        child: Column(children: [
          Expanded(flex: 16,child: Consumer<UpcomingOrderProvider>(
            builder: (context,orderState,child){
              if(orderState.isLoading){
                return Container(
                  alignment: Alignment.topCenter,
                  child:const CircularProgressIndicator(),
                );
              }
              else if(orderState.orders.isEmpty){
                return Showcase(
                  key: _order,
                  description: "This is the upcoming order section. The Pending and Upcoming orders will be shown here",
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
                description: "This is the upcoming order section. The Pending and Upcoming orders will be shown here",
                child: SingleChildScrollView(
                  child: Column(
                      children: orderState.orders.where((element) => (element.amount.contains(searchitem) || element.service_name!.toLowerCase().contains(searchitem.toLowerCase())))
                          .where((element) {
                        if(orderStatus==null)return true;
                        return element.vendorOrderStatus == orderStatus ;
                      }).map((e) => CustomOrderItem(order: e,ontap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleOrderPage(id:e.id,readOnly: false,))).then((value) => refresh(context));
                      },)).toList()),
                ),
              );
            },
          ))
        ]),
      ),
    );
  }
}

