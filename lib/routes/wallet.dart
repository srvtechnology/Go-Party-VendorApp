import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/wallet.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/provider/walletProvider.dart';
import 'package:utsavlife/core/repo/wallet.dart';

class WalletPage extends StatefulWidget {
  static const routeName = "/wallet";
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final TextEditingController _withdrawAmount = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _withdraw(BuildContext context,double withdrawAmount){
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(25),topLeft: Radius.circular(25))
        ),
        builder: (context){
          return Container(
            height: 250,
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Available to withdraw",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
                    const SizedBox(height: 10,),
                    Text("₹ $withdrawAmount",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20),),
                  ],
                ),
                const SizedBox(height: 20,),
                Form(
                  key: _formKey,
                  child: TextFormField(
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  controller: _withdrawAmount,
                  decoration: InputDecoration(
                      labelText: "Enter Amount",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)
                      )
                  ),
                ),),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: ()async{
                      if(_formKey.currentState!.validate()){
                        try{
                          Navigator.pop(context);
                          await withdrawAmountFromWallet(context.read<AuthProvider>(), _withdrawAmount.text);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Your withdrawal request has been successfully placed and forwarded to admin for approval")));
                        }
                        catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Some error occurred, Please try again.")));
                        }
                      }
                    }, child: Text("Withdraw"))
                  ],
                )
              ],
            ),
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (_)=>WalletProvider(context.read<AuthProvider>()),
      child: Consumer<WalletProvider>(
        builder: (context,state,child) {
          if(state.isLoading){
            return Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text("Wallet"),
            ),
            body: Stack(
              children: [
                Container(
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100),bottomRight: Radius.circular(100))
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20,),
                      Container(
                        height: 20.h,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                        padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[300]!,
                              offset: Offset(0,1),
                              spreadRadius: 1,
                              blurRadius: 1
                            )
                          ]
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total cash: ",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
                                Text(state.walletData.totalAmount.toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
                              ],
                            ),
                            const SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Available to withdraw: ",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15),),
                                Text(state.walletData.availableToWithdraw.toString(),style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15),),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            ElevatedButton(onPressed: (){
                              _withdraw(context,state.walletData.availableToWithdraw);
                            }, child: Text("Withdraw"),style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColorDark),)
                            ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                          child: Text("Latest Transactions",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),)),
                      Expanded(
                          child: Container(
                            padding: EdgeInsets.all(40),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(50),topRight: Radius.circular(50)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[300]!,
                                      offset: Offset(0,1),
                                      spreadRadius: 1,
                                      blurRadius: 1
                                  )
                                ]
                            ),
                            child: state.transactionData.isNotEmpty?SingleChildScrollView(
                              child: Column(
                                children: state.transactionData.map(
                                        (e) => TransactionTile(transaction: e,)
                                ).toList()
                              ),
                            ):Text("Looks like you do not have any Transactions !",textAlign: TextAlign.center,style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w500),),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );

  }
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  TransactionTile({Key? key,required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[300]!,
                offset: Offset(0,1),
                spreadRadius: 1,
                blurRadius: 1
            )
          ]
      ),
      child: Row(
        children: [
          Expanded(child: CircleAvatar(backgroundColor: Colors.redAccent,radius: 15,child: Text("D"),)),
          Expanded(flex:4,child: Center(child: Text(transaction.id.toString()))),
          Expanded(flex: 2,child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.centerRight,
              child: FittedBox(child: Text(transaction.amount.toString()))))
        ],
      ),
    );
  }
}
