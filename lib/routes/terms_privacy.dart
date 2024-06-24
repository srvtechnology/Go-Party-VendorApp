import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:utsavlife/core/components/appToolbar.dart';
import 'package:utsavlife/routes/webviewPage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsPrivacy extends StatefulWidget {
  static const routeName = "/termsPrivacy";

  String urlToLoad = "";
  String title = "";

  TermsPrivacy({Key? key, required this.title, required this.urlToLoad})
      : super(key: key);

  @override
  State<TermsPrivacy> createState() => _TermsPrivacyState();
}

class _TermsPrivacyState extends State<TermsPrivacy> {
  WebViewController controller = new WebViewController();
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        // onNavigationRequest: (navigation) {
        //   // if (navigation.url.contains("dashboard")) {
        //   //   Navigator.pop(context);
        //   //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        //   //       "You have successfully registered, Login to continue")));
        //   //   return NavigationDecision.prevent;
        //   // }
        //   if (navigation.url.contains("utsavlife.com") == false) {
        //     return NavigationDecision.prevent;
        //   }
        //   return NavigationDecision.navigate;
        // },
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          Logger().d(url);
          setState(() {
            loadingPercentage = 100;
          });
        },
      ))
      ..loadRequest(
        Uri.parse(widget.urlToLoad),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppToolbar(
          toolbarTitle: widget.title,
          onPressed: () => Navigator.pop(context),
        ),
        body: Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
