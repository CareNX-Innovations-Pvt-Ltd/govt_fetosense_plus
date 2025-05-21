import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/utils/definitions.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AuthTextField extends StatefulWidget {

  final String label;
  final bool obscureText;
  final TxtFieldOnChanged? onChanged;
  final TxtFieldValidator? validator;
  final TxtFieldOnSaved? onSaved;
  final TxtFieldOnSubmit? onSubmit;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? action;

  const AuthTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.onSubmit,
    this.controller,
    this.inputFormatters,
    this.action,
  });

  @override
  State<StatefulWidget> createState() =>_FieldState();

}
class _FieldState extends State<AuthTextField>{
  bool _obscureText = false;
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 3),
            blurRadius: 20.r,
            spreadRadius: 20.r,
            color: const Color(0x33B9B9B9),
          ),
        ],
      ),
      // height: 90.h,
      // width: 382.w,
      child: TextFormField(
        controller: widget.controller,
        onSaved: widget.onSaved,
        obscureText: _obscureText,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmit,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.action??TextInputAction.next,
        cursorColor: Theme.of(context).primaryColorDark,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 28.sp,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          errorMaxLines: 2,
          isDense: true,
          filled: true,
          errorStyle: const TextStyle(
            color: Color(0xFFFF0000),
            fontSize: 11,
            letterSpacing: 0.2,
          ),
          label: AutoSizeText(
            widget.label,
            style: TextStyle(
              color: const Color(0xFFB4B4B4),
              fontSize: 22.sp,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 16.h),
          suffixIcon: widget.obscureText ? IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,color: Colors.grey,size: 32.w,),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ):null,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12.r),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
