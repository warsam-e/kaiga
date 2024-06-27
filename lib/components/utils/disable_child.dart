import 'package:flutter/cupertino.dart';

class DisableChild extends StatelessWidget {
  final Widget child;
  final bool disable;
  final int? milliseconds;
  const DisableChild(
    this.child, {
    required this.disable,
    this.milliseconds,
    super.key,
  });

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: disable ? 0.3 : 1.0,
        duration: Duration(milliseconds: milliseconds ?? 200),
        child: disable ? IgnorePointer(child: child) : child,
      );
}
