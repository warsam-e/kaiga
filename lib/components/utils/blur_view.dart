import 'dart:ui';

import 'package:flutter/cupertino.dart';

class BlurView extends StatelessWidget {
  final Widget child;
  const BlurView({required this.child, super.key});

  @override
  Widget build(BuildContext context) => ClipRect(
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: child,
        ),
      );
}
