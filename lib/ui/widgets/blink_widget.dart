import 'package:flutter/material.dart';

class BlinkingWidget extends AnimatedWidget {
  final Widget child;
  final Duration blinkDuration;

  bool isBlinking = false;

  BlinkingWidget({Key? key, required this.child, this.blinkDuration = const Duration(seconds: 1), required AnimationController listenable})
      : super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Opacity(
      opacity: (1.0 - animation.value).clamp(0.0, 1.0),
      child: child,
    );
  }

  static create(Widget child, AnimationController controller) {
     //controller.repeat(reverse: true);
    return BlinkingWidget(listenable: controller, child: child);
  }

  void startBlinking() {
    if (!isBlinking) {
      (listenable as AnimationController).repeat(reverse: true);
    }
  }

  void stopBlinking() {
    if (isBlinking) {
      (listenable as AnimationController).stop();
    }
  }
  @override
  void dispose() {
    (listenable as AnimationController).dispose();
  }

}
