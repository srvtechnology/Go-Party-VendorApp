import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:utsavlife/core/provider/AuthProvider.dart';
import 'package:utsavlife/core/repo/auth.dart';
import 'package:utsavlife/core/utils/UIColor.dart';

import '../imageViewPage.dart';
import '../pdfView.dart';

class DocumentTab extends StatefulWidget {
  const DocumentTab({super.key});

  @override
  State<DocumentTab> createState() => _DocumentTabState();
}

class _DocumentTabState extends State<DocumentTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Column(
          children: [
            SizedBox(height: 25,),
            FilePickerRow(
                imageUrl: auth.user?.panCardUrl,
                imageName: "Pan Card",
                imageKey: "img1",
             ),
            FilePickerRow(
                imageUrl: auth.user?.kycUrl,
                imageName: "KYC",
                imageKey: "img2",
             ),
            FilePickerRow(
                imageUrl: auth.user?.gstUrl,
                imageName: "GST",
                imageKey: "img4",
             ),
            FilePickerRow(
                imageUrl: auth.user?.vendorUrl,
                imageName: "Vendor",
                imageKey: "img3",
             ),
          ],
        );
      },
    );
  }


}

class FilePickerRow extends StatefulWidget {
  final String? imageUrl;
  final String imageName;
  final String imageKey;

  final VoidCallback? onChooseFile;

  const FilePickerRow({
    required this.imageUrl,
    required this.imageName,
    required this.imageKey,
     this.onChooseFile =null,
  });

  @override
  _FilePickerRowState createState() => _FilePickerRowState();
}

class _FilePickerRowState extends State<FilePickerRow> {
  String? _uploadingImageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      child: Row(

        children: [
          // Left image with loading progress
          Container(
            height: 80,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: UIColor.theme_color),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: _uploadingImageUrl == null
                  ? CachedNetworkImage(
                imageUrl: widget.imageUrl ?? "",

                fit: BoxFit.cover,
                // Ensures the image fits within the box
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 20,  // Set the width of the CircularProgressIndicator
                    height: 20, // Set the height of the CircularProgressIndicator
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0, // Adjust the thickness of the progress indicator
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
                  : Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    File(_uploadingImageUrl!),

                    fit:
                    BoxFit.fill, // Ensures the image fits within the box
                  ),
                  Center(
                    child: SizedBox(
                      width: 20,  // Set the width of the CircularProgressIndicator
                      height: 20, // Set the height of the CircularProgressIndicator
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0, // Adjust the thickness of the progress indicator
                      ),
                    ),
                  ), // Show progress while uploading
                ],
              ),
            )
          ),
          SizedBox(width: 16), // Spacing between image and text

          // Middle text (image name)
          Expanded(
            child: Text(
              widget.imageName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Right button (Choose File)
          OutlinedButton(
            onPressed: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _uploadingImageUrl = pickedFile.path;
                });

               Map<String,dynamic> data = {
                 widget.imageKey :  await MultipartFile.fromFile(_uploadingImageUrl!)
               };

              await completeRegistration3(Provider.of<AuthProvider>(context, listen: false), data);


                await Provider.of<AuthProvider>(context,listen: false).getUserWithNotifyListener();
                setState(() {
                  _uploadingImageUrl = null;
                });
                // Simulate a delay for uploading (Replace with actual upload code)
               // await Future.delayed(Duration(seconds: 2));

                // After uploading, reset the _uploadingImageUrl

                // Handle the actual file selection
                widget.onChooseFile?.call();
              }
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              side: BorderSide(color: UIColor.theme_color, width: .5),
            ),
            child: Text('Choose File', style: TextStyle(color: UIColor.theme_color),),
          ),
        ],
      ),
    );
  }
}
