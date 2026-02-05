// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';

class custtomButton extends StatelessWidget {
  const custtomButton({
    super.key,
    this.isTransparent = false,
    this.isLarge = false,
    this.onPressed,
    this.height,
    this.width,
    required this.text,
  });

  final bool isTransparent;
  final bool isLarge;
  final String text;
  final double? width;
  final double? height;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 60,
        width: isLarge ? double.infinity : 160,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                side: const BorderSide(width: 0.10),
                backgroundColor:
                    isTransparent ? Colors.transparent : primaryButt,
                shadowColor: Colors.transparent,
                minimumSize: Size( 
                  width ?? (isLarge ? 200 : 120),
                  height ?? (isLarge ? 50 : 45),

                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: onPressed,
            child: Text(
              text,
              style: bodyTextsStyle.copyWith(
                  color: isTransparent ? blackColor : whiteColor, fontSize: 22),
            )));
  }
}
