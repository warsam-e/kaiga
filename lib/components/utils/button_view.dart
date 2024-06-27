import 'package:flutter/cupertino.dart';

/// [ButtonView] is a [StatelessWidget] that wraps a [CupertinoButton] with a
/// [child] and [onPressed] function.
///
/// the point of making this widget is to make the code cleaner and easier to read.
/// Also [CupertinoButton] adds a lot of padding to the button by default,
/// so this widget is used to remove that padding.
class ButtonView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final void Function() onPressed;

  const ButtonView(
    this.child, {
    super.key,
    required this.onPressed,
    this.padding = const EdgeInsets.all(0),
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: padding,
      color: color,
      minSize: 0,
      borderRadius: borderRadius,
      child: child,
      onPressed: () {
        onPressed();
      },
    );
  }
}
