import 'package:flutter/material.dart';

class AppColors{
  static const Color  us1 = Color(0xFF00f500);
  static const Color  us2 = Color(0xFFfad400);
  static const Color  uc = Color(0xFF4eceff);
}

abstract class ThemeColors {
  Color get primaryLight;
  Color get primaryDark;

//factory ThemeColors.dark()=> Dark();
//factory ThemeColors.light()=> Light();
}


class MyColorScheme extends ThemeExtension<MyColorScheme> {
  final Color? primaryLight;
  final Color? primaryDark;

  MyColorScheme({
    this.primaryLight,
    this.primaryDark,
  });

  @override
  ThemeExtension<MyColorScheme> copyWith({ThemeColors? colors}) {
    return MyColorScheme(
      primaryLight: colors?.primaryLight ?? primaryLight,
      primaryDark: colors?.primaryDark ?? primaryDark,
    );
  }

  @override
  ThemeExtension<MyColorScheme> lerp(
      ThemeExtension<MyColorScheme>? other, double t) {
    if (other is! MyColorScheme) {
      return this;
    }
    return MyColorScheme(
      primaryLight:
      Color.lerp(primaryLight, other.primaryLight, t) ?? primaryLight,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t) ?? primaryDark,
    );
  }
}

class DarkScheme extends ColorScheme implements ThemeColors {
  const DarkScheme() : super.dark();

  @override
  Color get background => const Color(0XFF000749);

  @override
  Brightness get brightness => Brightness.dark;

  @override
  Color get primary => const Color(0XFF1F1E26);

  @override
  Color get primaryLight => const Color(0XFF1F1E26);

  @override
  Color get primaryDark => const Color(0XFF080808);

  @override
  Color get primaryContainer => const Color(0XFF1F1E26);

  //@override
  //Color get primaryVariant => const Color(0XFF358BCA);

  @override
  Color get secondary => const Color(0XFFFFFFFF);

  @override
  Color get secondaryContainer => const Color(0XFF302F33);

  /*@override
  Color get secondaryVariant => throw UnimplementedError();*/

  @override
  Color get tertiary => const Color(0XFF141829);

  @override
  Color get tertiaryContainer => const Color(0X33464646);

  @override
  Color get shadow => const Color(0X47737171);

  @override
  Color get onPrimary => const Color(0XFF368BC9);

  @override
  Color get onPrimaryContainer => const Color(0XFF151740);

  @override
  Color get onSecondary => const Color(0XFFD0D9E5);

  @override
  Color get onSecondaryContainer => const Color(0XFFA6A6A6);

  @override
  Color get onTertiary => Colors.teal;

  @override
  Color get onTertiaryContainer => const Color(0XFFB6B6B6);

  /*@override
  Color get errorContainer => throw UnimplementedError();*/

  /*@override
  Color get inversePrimary => throw UnimplementedError();*/

  /*@override
  Color get inverseSurface => throw UnimplementedError();*/

  /*@override
  Color get onBackground => throw UnimplementedError();*/

  /*@override
  Color get onError => throw UnimplementedError();*/

  /*@override
  Color get onErrorContainer => throw UnimplementedError();*/

  /*@override
  Color get onInverseSurface => throw UnimplementedError();*/

  /*@override
  Color get onSurface => throw UnimplementedError();*/

  /*@override
  Color get onSurfaceVariant => throw UnimplementedError();*/

  /*@override
  Color get outline => throw UnimplementedError();*/

  /*@override
  Color get surface => throw UnimplementedError();*/

  @override
  Color get surfaceTint => const Color(0XFF535050);

  /*@override
  Color get surfaceVariant => throw UnimplementedError();*/

  /*@override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) {
    throw UnimplementedError();
  }*/

  /*@override
  String toStringShort() {
    throw UnimplementedError();
  }*/

}

class LightScheme extends ColorScheme implements ThemeColors {
  /*@override
  Color primaryColor =  const Color(0XFFD0D9E5);
  @override
  Color primaryColorLight =  const Color(0XFFF2F8FF);
  @override
  Color primaryColorDark =  const Color(0XFFD0D9E5).withOpacity(0.87);

  @override
  Color primaryContainerColor =  const Color(0XFFFFFFFF).withOpacity(0.60);//panel tile color

  @override
  Color secondaryColor =  const Color(0XFF000749);
  @override
  Color shadowColor =  const Color(0XFF737171).withOpacity(0.28);//panel tile shadow

  @override
  Color tertiaryContainerColor =  const Color(0X33464646);
  @override
  Color onTertiaryContainerColor =  const Color(0XFFB6B6B6);

  @override
  Color tertiaryColor =  const Color(0X33180F0F);
  @override
  Color secondaryContainerColor =  const Color(0XFFD0D9E5);
  @override
  Color onSecondaryContainerColor =  const Color(0XFFA6A6A6);*/

  const LightScheme() : super.light();

  @override
  Color get background => const Color(0XFF000749);

  @override
  Brightness get brightness => Brightness.light;

  @override
  Color get primary => const Color(0XFFD0D9E5);

  @override
  Color get primaryLight => const Color(0XFFF2F8FF);

  @override
  Color get primaryDark => const Color(0XFFC2CADA).withOpacity(0.69);

  @override
  Color get primaryContainer => const Color(0XFFFFFFFF).withOpacity(0.60);

  // @override
  // Color get primaryVariant => const Color(0XFFBDCDE3);

  @override
  Color get secondary => const Color(0XFF000749);

  @override
  Color get secondaryContainer => const Color(0XFFD0D9E5);

  /*@override
  Color get secondaryVariant => throw UnimplementedError();*/

  @override
  Color get tertiary => const Color(0X33180F0F);

  @override
  Color get tertiaryContainer => const Color(0XFFFFFFFF).withOpacity(0.8);

  @override
  Color get shadow => const Color(0XFF737171).withOpacity(0.28);

  @override
  Color get onPrimary => Colors.white;

  @override
  Color get onPrimaryContainer => const Color(0XFF151740);

  @override
  Color get onSecondary => const Color(0XFFD0D9E5);

  @override
  Color get onSecondaryContainer => const Color(0XFFA6A6A6);

  @override
  Color get onTertiary => const Color(0XFFB6B6B6);

  @override
  Color get onTertiaryContainer => const Color(0XFF000749);

/*@override
  Color get errorContainer => throw UnimplementedError();*/

/*@override
  Color get inversePrimary => throw UnimplementedError();*/

/*@override
  Color get inverseSurface => throw UnimplementedError();*/

/*@override
  Color get onBackground => throw UnimplementedError();*/

/*@override
  Color get onError => throw UnimplementedError();*/

/*@override
  Color get onErrorContainer => throw UnimplementedError();*/

/*@override
  Color get onInverseSurface => throw UnimplementedError();*/

/*@override
  Color get onSurface => throw UnimplementedError();*/

/*@override
  Color get onSurfaceVariant => throw UnimplementedError();*/

/*@override
  Color get outline => throw UnimplementedError();*/

/*@override
  Color get surface => throw UnimplementedError();*/

  @override
  Color get surfaceTint => const Color(0XFFE9ECF2);

/*@override
  Color get surfaceVariant => throw UnimplementedError();*/

/*@override
  DiagnosticsNode toDiagnosticsNode({String? name, DiagnosticsTreeStyle? style}) {
    throw UnimplementedError();
  }*/

/*@override
  String toStringShort() {
    throw UnimplementedError();
  }*/
}
