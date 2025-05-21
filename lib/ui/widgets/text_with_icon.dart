import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TextWithIcon extends StatelessWidget {
  IconData icon;
  String text;
  double? size = 14;

  TextWithIcon({super.key, required this.icon, required this.text, this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: Icon(icon, size: size),
            ),
            Text(
              this.text,
                style: TextStyle(
                    fontSize: 26.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600)
            ),
          ],
        ));
  }
}
