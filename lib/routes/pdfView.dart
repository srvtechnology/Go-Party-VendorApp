import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class pdfViewer extends StatelessWidget {
  String pdfUrl;
  pdfViewer({Key? key,required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: SfPdfViewer.network(pdfUrl),
      ),
    );
  }
}
