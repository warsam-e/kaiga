import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ListenableView<T> extends StatelessWidget {
  final ValueListenable<T> valueListenable;
  final Widget Function(T value) builder;

  const ListenableView(
    this.valueListenable, {
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<T>(
        valueListenable: valueListenable,
        builder: (context, value, child) => builder(value),
      );
}
