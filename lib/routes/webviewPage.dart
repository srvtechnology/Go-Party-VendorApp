import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class webViewer extends StatefulWidget {
  String url ;

  webViewer({Key? key,required this.url}) : super(key: key);

  @override
  State<webViewer> createState() => _webViewerState();
}

class _webViewerState extends State<webViewer> {
  WebViewController controller=new WebViewController();
  int loadingPercentage = 0;
  @override
  void initState() {
    super.initState();
    controller
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (navigation) {
          // if (navigation.url.contains("dashboard")) {
          //   Navigator.pop(context);
          //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
          //       "You have successfully registered, Login to continue")));
          //   return NavigationDecision.prevent;
          // }
          if (navigation.url.contains("utsavlife.com") == false) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
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
          setState(() {
            loadingPercentage = 100;
          });
        },
      ))
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
      )
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
