
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircleIconButton extends StatelessWidget{
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? splashColor;
  final bool isSelected;
  final String? title;
  final EdgeInsets? margin;
  final double? size;
  final bool showShadows;
  final Widget? num;

  const CircleIconButton({super.key, required this.icon, this.onTap,this.onLongTap, this.backgroundColor, this.splashColor, this.isSelected = false, this.title, this.margin, this.size, this.iconColor, this.showShadows = true,this.num});

  @override
  Widget build(BuildContext context) {
   return Column(
     children: [
       Container(
         margin: margin??EdgeInsets.only(top: 8.h,bottom: 8.h),
         decoration:  BoxDecoration(
           gradient: isSelected ?
           LinearGradient(
               begin: Alignment.centerLeft,
               end: Alignment.centerRight,

               colors: [
                 Theme.of(context).colorScheme.onPrimary,
                 Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
               ]):
           LinearGradient(
               begin: Alignment.centerLeft,
               end: Alignment.centerRight,

               colors: [
                 backgroundColor??Theme.of(context).colorScheme.onTertiary,
                 backgroundColor??Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
               ]),
           boxShadow: showShadows? [
             if(isSelected)
             const BoxShadow(
               color: Colors.black38,
               blurRadius: 16.0,
               offset: Offset(8.0, 8.0),
             ),
           ]:null,
           borderRadius: BorderRadius.all(Radius.circular(50.w)),
         ),
         //color: isSelected ?  Theme.of(context).colorScheme.secondary:backgroundColor??Theme.of(context).colorScheme.tertiaryContainer, // Button color
         child: ClipOval(
           child: Material(
             color: Colors.transparent,
             child: InkWell(
               highlightColor:  isSelected ?  Theme.of(context).colorScheme.secondary:backgroundColor??Theme.of(context).colorScheme.tertiaryContainer, // Button color
               splashColor: isSelected ?backgroundColor??Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.secondary, // Splash color
               onTap: onTap,
               onLongPress: onLongTap,
               child: SizedBox(
                   width: size??60.w,
                   height: size??60.w,
                   child: Center(
                     child: num ?? Icon(
                       icon,size:36.w,
                       color: iconColor??(isSelected ? backgroundColor??Theme.of(context).colorScheme.secondaryContainer:Theme.of(context).colorScheme.secondary),
                     ),
                   )
               ),
             ),
           ),
         ),
       ),
       if(title!=null)
       Text(title!,style: Theme.of(context).textTheme.labelSmall,)
     ],
   );
  }

}