import 'package:utsavlife/core/utils/themData.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TramsAndConditionsCheckBox extends StatelessWidget {
  final bool value;
  final Function(bool? value) onChanged;
  const TramsAndConditionsCheckBox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        // alignment: Alignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Theme(
          //   data: Theme.of(context).copyWith(
          //     unselectedWidgetColor: primaryColor,
          //   ),
          //   child: Checkbox(
          //     value: value,
          //     onChanged: onChanged,
          //     checkColor: Colors.white,
          //     activeColor: primaryColor,
          //   ),
          // ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Center(
                  // alignment: Alignment.center,
                  child: Text.rich(
                      // alignment: Alignment.center,
                      TextSpan(
                          text:
                              'By logging in, you are agreeing to our terms listed in the',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                    TextSpan(
                        text: ' legal information section ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigator.pushNamed(
                            //     context, TermsAndCondition.routeName);
                          }),
                    TextSpan(
                        text: ' and our ',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'privacy policy',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: primaryColor,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigator.pushNamed(
                                  //     context, PrivacyPolicy.routeName);
                                })
                        ])
                  ]))),
            ),
          ),
        ]);
  }
}
