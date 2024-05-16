import 'package:flutter/material.dart';

import '../utils/UIColor.dart';

class AppToolbar extends StatelessWidget implements PreferredSizeWidget {

  String toolbarTitle;
  void Function()? onPressed;

   AppToolbar({super.key, required this.toolbarTitle,  required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: UIColor.theme_color,
      leading: IconButton(
        color: UIColor.toolbar_content_color,
        onPressed: onPressed,
        icon: Icon(Icons.arrow_back_ios),
      ),
      elevation: 0,
      centerTitle: true,
      title: Text(
        toolbarTitle,
        style: TextStyle(fontWeight: FontWeight.w400,color: UIColor.toolbar_content_color),
      ),
      iconTheme: IconThemeData(color: UIColor.toolbar_content_color),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

}
