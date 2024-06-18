import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:utsavlife/core/provider/OrderProvider.dart';
import 'package:utsavlife/core/utils/UIColor.dart';

Future<void> showRejectStatus(
    BuildContext context, Function(String?) onRejected) async {
  TextEditingController controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();


  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(16),

          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'Please provide the reason',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close),)
                  ],
                ),
                SizedBox(height: 8.0),

                SizedBox(height: 24.0),
                Container(
                /*  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey),
                  ),*/
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a reason';
                      }
                      return null;
                    },
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(

                      hintText: "Enter reason",
                      contentPadding: EdgeInsets.all(8.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color:  Colors.grey),
                      ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: UIColor.theme_color),
                      ),

                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          fixedSize: Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))

                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            onRejected(controller.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please provide a reason")),
                            );
                          }
                        },
                        child: Text(
                          'Reject Order',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  /*  SizedBox(width: 8.0),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            Navigator.pop(context);
                            onRejected(controller.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please provide a reason")),
                            );
                          }
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    )*/
                  ],
                ),
                SizedBox(height: 36.0),
              ],
            ),
          ),
        ),
      );
    },
  );
}



Future<void> reject(BuildContext context, String reason, SingleOrderProvider singleOrderState) async{
  try{
    String message = await singleOrderState.rejectOdr(reason);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }catch(e){
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
  };
}
