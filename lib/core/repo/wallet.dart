import 'package:dio/dio.dart';
import 'package:utsavlife/config.dart';
import 'package:utsavlife/core/models/wallet.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/utils/logger.dart';

Future<WalletModel> getWalletDetails(AuthProvider auth)async{
  try{
    Response response = await Dio().get(
        "${APIConfig.baseUrl}/api/manage-vendor/wallet",
        options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
        )
    );
    return WalletModel.fromJson(response.data);
  }catch(e){
    if(e is DioError){
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    rethrow;
  }
}

Future<List<Transaction>> getTransactionDetails(AuthProvider auth)async{
  try{
    Response response = await Dio().get(
        "${APIConfig.baseUrl}/api/manage-vendor/transactions",
        options: Options(
          headers: {
            "Authorization":"Bearer ${auth.token}"
          }
        )
    );
    CustomLogger.debug(response.data);
    List<Transaction> data=[];
    for (var i in response.data["transactions"]){
      data.add(Transaction.fromJson(i));
    }
    CustomLogger.debug(response.data);
    return data;
  }catch(e){
    if(e is DioError){
      CustomLogger.error(e.response!.data);
    }
    CustomLogger.error(e);
    rethrow;
  }
}

Future<bool> withdrawAmountFromWallet(AuthProvider auth, String amount) async {
  try {
    Response response = await Dio().post(
      "${APIConfig.baseUrl}/api/manage-vendor/withdraw",
      data: {
        "wallet_amount": amount,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${auth.token}', // assuming you need auth
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // You can add extra checks like `response.data["status"] == "success"`
      return true;
    } else {
      CustomLogger.error("Failed: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    if (e is DioError) {
      CustomLogger.error(e.response?.data ?? e.message);
    } else {
      CustomLogger.error(e.toString());
    }
    return false;
  }
}
//
// Widget _BankDetailsInfo(AuthProvider auth){
//   return  (auth.user!.bankDetails == null && BankEditMode==false)?
//   Container(
//     padding: EdgeInsets.all(40),
//     child: Column(
//       children: [
//         Text("Looks like you have not uploaded your bank details.",style: TextStyle(fontSize: 18.sp),),
//         Divider(height: 40,),
//         OutlinedButton(onPressed: (){
//           setState(() {
//             BankEditMode = true;
//           });
//         }, child: Text("Upload"))
//       ],
//     ),
//   )
//       :
//   Form(
//     key: _bankFormKey,
//     child: Column(
//       children: [
//         Container(
//           alignment: Alignment.bottomRight,
//           child: IconButton(onPressed: (){
//             setState(() {
//               BankEditMode = !BankEditMode;
//             });
//           }, icon: Icon(Icons.edit,color: BankEditMode?Theme.of(context).primaryColor:null),),
//         ),
//         _CustomText(context, editMode:BankEditMode,title: "Holder Name",content: auth.user!.bankDetails?.holderName ?? ""),
//         _CustomText(context, editMode:BankEditMode,title: "Account Number",content: auth.user!.bankDetails?.accountNumber ?? "",accountConfirm: true),
//         if(BankEditMode)
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Expanded(
//                     child: InputDecorator(
//                       decoration: InputDecoration(
//                           label:Container(
//                             margin: const EdgeInsets.only(left: 20),
//                             child: Text("Account Type"),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(horizontal:0),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           )
//                       ),
//                       child: ExpansionTile(
//                         trailing:Text(""),
//                         key: GlobalKey(),
//                         title: Text(selectedAccountType.title),
//                         children: AccountTypes.map((e) => ListTile(
//                           onTap: (){
//                             setState(() {
//                               selectedAccountType = e ;
//                             });
//                           },
//                           title: Text(e.title),
//                         )).toList(),
//                       ),
//                     )
//                 ),
//               ],
//             ),
//           )
//         else _CustomText(context, title: "Account Type", content: AccountTypes.firstWhere((element) => element.value==auth.user!.bankDetails?.accountType,orElse:()=> AccountTypes[0]).title, editMode: BankEditMode),
//         _CustomText(context, editMode:BankEditMode,title: "Bank Name",content: auth.user!.bankDetails?.bankName ?? ""),
//         _CustomText(context, editMode:BankEditMode,title: "Branch Name",content: auth.user!.bankDetails?.branchName ?? ""),
//         _CustomText(context, editMode:BankEditMode,title: "IFSC Code",content: auth.user!.bankDetails?.ifscNumber ?? ""),
//         if(BankEditMode)
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
//             child: Row(
//               children: [
//                 Expanded(child: passbookPath==null?Text("Cancelled Checkbook / Passbook Front page"):Container(alignment: Alignment.centerLeft,height: 80,width: 80,child:Image.file(File(passbookPath!)))),
//                 SizedBox(width: 40,),
//                 OutlinedButton(onPressed: ()async{
//                   XFile? file =  await ImagePicker().pickImage(source: ImageSource.gallery);
//                   if(file!=null){
//                     setState(() {
//                       passbookPath = file.path;
//                     });
//                   }
//                 }, child: Text(passbookPath==null?"Choose":"Change"))
//               ],
//             ),
//           ),
//         if(BankEditMode)
//           Container(
//             alignment: Alignment.center,
//             child: OutlinedButton(
//               style: OutlinedButton.styleFrom(
//                   side: BorderSide(color: Theme.of(context).primaryColor,width: 1,)
//               ),
//               onPressed: () {
//                 if(_bankFormKey.currentState!.validate()){
//                   setBankChanges(auth);
//                   setState(() {
//                     BankEditMode = false ;
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully updated")));
//                 }
//               },
//               child: Text("Save"),
//             ),
//           ),
//       ],
//     ),
//   );
//
// }