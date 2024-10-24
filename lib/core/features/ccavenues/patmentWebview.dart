import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:utsavlife/core/features/ccavenues/models/enc_val_res.dart';
import 'package:utsavlife/core/features/ccavenues/models/payment_res.dart';
import 'package:utsavlife/core/features/ccavenues/payemntStatusview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final GenerateOrderValue generateOrderValue;
  const PaymentWebView({
    Key? key,
    required this.generateOrderValue,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  WebViewController? controller;
  bool isloading = false;
  double progress = 0;
  @override
  void initState() {
    super.initState();
    loadPaymentView();
    log(jsonEncode(widget.generateOrderValue.toMap()), name: 'URL PAY');
  }

  loadPaymentView() {
    String url =
        "https://secure.ccavenue.com/transaction.do?command=initiateTransaction&encRequest=${widget.generateOrderValue.encVal}&access_code=${widget.generateOrderValue.accessCode}";
    log(url, name: 'PaymentWebView');
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            log(url, name: 'URL PAY');
            if (url == widget.generateOrderValue.redirectUrl) {
              setState(() => isloading = true);
            }
            if (url == widget.generateOrderValue.cancelUrl) {
              setState(() {
                isloading = true;
              });
            }
          },
          onPageFinished: (String url) {
            log(url, name: 'URL PAY');
            log('Page finished loading: ${widget.generateOrderValue.cancelUrl}',
                name: 'PaymentWebView');
            try {
              controller!
                  .runJavaScriptReturningResult(
                      "document.documentElement.innerText")
                  .then((value) {
                // remove '\' from value
                PaymentRes? paymentRes;
                if (url == widget.generateOrderValue.redirectUrl ||
                    url == widget.generateOrderValue.cancelUrl) {
                  final res = value.toString().replaceAll('\\', '');
                  // remove '"' from value fast and last
                  final res2 =
                      res.toString().substring(1, res.toString().length - 1);
                  log(res2.toString(), name: 'PaymentWebView');
                  paymentRes = paymentResFromJson(res2);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PaymentStatusView(paymentRes: paymentRes)));
                }
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Something went wrong! Try again")));
              Navigator.pop(context);
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url
                .startsWith('${widget.generateOrderValue.cancelUrl}')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Payment"),
      // ),
      body: SafeArea(
        child: isloading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : progress != 1.0
                ? Center(
                    child: CircularProgressIndicator(
                      value: progress,
                      color: Colors.green,
                    ),
                    // child: CircularPercentIndicator(
                    //   radius: 60.0,
                    //   lineWidth: 8.0,
                    //   percent: progress,
                    //   center: Text(
                    //     "${(progress * 100).toStringAsFixed(0)}%",
                    //     style: const TextStyle(
                    //         fontWeight: FontWeight.bold, fontSize: 20.0),
                    //   ),
                    //   progressColor: Colors.green,
                    // ),
                  )
                // LinearProgressIndicator(
                //     value: progress,
                //     backgroundColor: Colors.white,
                //     valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                //   )
                : SafeArea(
                    child: controller == null
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : WebViewWidget(controller: controller!)),
      ),
    );
  }
}
