import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/models/order.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/order.dart';

class PartialPaymentPage extends StatefulWidget {
  final OrderModel order;

  const PartialPaymentPage({Key? key,required this.order}) : super(key: key);

  @override
  State<PartialPaymentPage> createState() => _PartialPaymentPageState();
}

class _PartialPaymentPageState extends State<PartialPaymentPage> {
  TextEditingController _controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Partial Payment"),
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
                      offset: Offset(0,0.5),
                      color: Colors.grey[400]!,
                      blurRadius: 1,
                      spreadRadius: 1
                    ),
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Details",style: TextStyle(fontWeight: FontWeight.w500),),
                    const SizedBox(height: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text("₹ ${widget.order.amount}",style: Theme.of(context).textTheme.headlineSmall,),
                        ),
                        Row(
                          children: [
                            Expanded(child: DetailTile("Status", widget.order.vendorOrderStatus == VendorOrderStatus.approved?"Accepted":widget.order!.vendorOrderStatus == VendorOrderStatus.pending?"Pending":"Rejected")),
                            Expanded(child: DetailTile("Event Name", widget.order.category!)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: DetailTile("Category", widget.order.category!)),
                            Expanded(child: DetailTile("Payment Status", widget.order.paymentStatus==OrderPaymentStatus.partial?"Partial Payment":"Payment Completed",)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            const SizedBox(height: 40,),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0,0.5),
                        color: Colors.grey[400]!,
                        blurRadius: 1,
                        spreadRadius: 1
                    ),
                  ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Enter Amount to be paid",style: TextStyle(fontWeight: FontWeight.w600),),
                  const SizedBox(height: 20,),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      validator: (text){
                        if(text==null || text.isEmpty)return "Please enter an amount";
                      },
                      controller: _controller,
                      decoration: InputDecoration(
                          labelText: "Amount",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: (){
                        _payAmount();
                      }, child: Text("Pay")),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _payAmount()async{
    if(formKey.currentState!.validate()){
      try{
        await payPartialAmount(context.read<AuthProvider>(), widget.order.id, _controller.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Amount Paid")));
        Navigator.pop(context);
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error occured, please try later")));
        //Navigator.pop(context);
      }
    }
  }
  Widget DetailTile(String header,String body){
    if(body=="")body="Not set";
    return Container(
        constraints: BoxConstraints(
            maxHeight: 40.h
        ),
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        child: TextFormField(
          maxLines: null,
          decoration: InputDecoration(
              labelText: header,
              border: InputBorder.none
          ),
          initialValue: body,
          readOnly: true,
        )
    );
  }
}
