import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/utils/definitions.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AuthButton extends StatelessWidget {
  final bool disabled;
  final OnTap? onTap;
  final String text;
  const AuthButton({
    super.key,
    this.disabled = false,
    this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      autofocus: true,
      onTap: disabled ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: disabled ? const Color(0xBF616D79) : null,
          gradient: disabled
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6A60ED),
                    Color(0xFF443CAF),
                  ],
                ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: AutoSizeText(
            text,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color:
                  disabled ? const Color(0xFFFFFFFF) : const Color(0xFFF9F6F6),
            ),
          ),
        ),
      ),
    );
  }
}
