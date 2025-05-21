import 'package:flutter/material.dart';

class AuthScaffoldBackground extends StatelessWidget {
  final Widget child;
  const AuthScaffoldBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD0D1DB),
              Color(0xFF010848),
              Color(0xFF0B123F),
            ],
            stops: [
              0,
              0.45,
              1,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
