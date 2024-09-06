import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:utsavlife/core/utils/UIColor.dart';

class HtmlInputBox extends StatefulWidget {
  String text;

  String hint;

  void Function(String) onTextChange;

  HtmlInputBox(
      {super.key,
      required this.text,
      this.hint = "Enter your description",
      required this.onTextChange});

  @override
  State<HtmlInputBox> createState() => _HtmlInputBoxState();
}

class _HtmlInputBoxState extends State<HtmlInputBox> {
  final QuillEditorController controller = QuillEditorController();

  @override
  void initState() {
    controller.onTextChanged(widget.onTextChange);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillHtmlEditor(
          text: widget.text,
          hintText: widget.hint,
          controller: controller,
          isEnabled: true,
          minHeight: 300,
          textStyle: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
          hintTextAlign: TextAlign.start,
          padding: const EdgeInsets.only(left: 10, top: 5),
          hintTextPadding: EdgeInsets.zero,
          hintTextStyle: const TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: 14.0,
            color: UIColor.hint_text_color,
            fontWeight: FontWeight.normal,
          ),
/*          onFocusChanged: (hasFocus) => debugPrint('has focus $hasFocus'),
          onTextChanged: (text) => debugPrint('widget text change $text'),
          onEditorCreated: () => debugPrint('Editor has been loaded'),
          //  onEditingComplete: (s) => debugPrint('Editing completed $s'),
          onEditorResized: (height) =>
              debugPrint('Editor resized $height'),
          onSelectionChanged: (sel) =>
              debugPrint('${sel.index},${sel.length}'),*/
          /* loadingBuilder: (context) {
                                       return const Center(
                                           child: CircularProgressIndicator(
                                             strokeWidth: 0.4,
                                           ));},*/
        ),
        ToolBar(
          toolBarColor: Colors.cyan.shade50,
          activeIconColor: Colors.green,
          padding: const EdgeInsets.all(8),
          iconSize: 20,
          controller: controller,
          customButtons: [
            InkWell(onTap: () {}, child: const Icon(Icons.favorite)),
            InkWell(onTap: () {}, child: const Icon(Icons.add_circle)),
          ],
        )
      ],
    );
  }
}
