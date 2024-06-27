import 'package:flutter/foundation.dart';

/*
  ValueNotifierList<T> is a class that extends ChangeNotifier and implements ValueListenable<List<T>>.

  It's like ValueNotifier<T> but for lists, it has the same methods as a List<T> and it notifies listeners when the list changes.
*/
class ValueNotifierList<T> extends ChangeNotifier
    implements ValueListenable<List<T>> {
  final List<T> _value;

  ValueNotifierList(this._value);

  @override
  List<T> get value => _value;

  set value(List<T> newValue) {
    if (_value == newValue) {
      return;
    }
    _value.clear();
    _value.addAll(newValue);
    notifyListeners();
  }

  void add(T valueToAdd) {
    value = List<T>.from([...value, valueToAdd]);
  }

  void prepend(T valueToAdd) {
    value = List<T>.from([valueToAdd, ...value]);
  }

  void clear() {
    value = List<T>.from([]);
  }

  void addAll(List<T> valuesToAdd) {
    value = List<T>.from([...value, ...valuesToAdd]);
  }

  void replaceAll(List<T> newValues) {
    value = List<T>.from(newValues);
  }

  void replaceRange(int start, int end, List<T> newValues) {
    value = List<T>.from(value
      ..replaceRange(start, end, newValues)
      ..toList());
  }

  void replaceAt(int index, T valueToReplace) {
    value =
        List<T>.from(value..replaceRange(index, index + 1, [valueToReplace]));
  }

  T get first => value.first;

  T removeFirst() {
    final item = value.removeAt(0);
    value = List<T>.from(value);
    return item;
  }

  void remove(T valueToRemove) {
    value =
        List<T>.from(value.where((value) => value != valueToRemove).toList());
  }

  void removeAt(int index) {
    value = List<T>.from(value..removeAt(index));
  }

  void removeWhere(bool Function(T) test) {
    value = List<T>.from(value.where((value) => !test(value)).toList());
  }
}
