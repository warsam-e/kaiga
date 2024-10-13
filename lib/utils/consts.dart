import 'package:flutter/cupertino.dart';

/// The Consts class contains constants used throughout the app.
/// Stuff like colors, text styles, and themes.
abstract class Consts {
  static const primaryColor = Color.fromARGB(255, 47, 131, 249);

  static const theme = CupertinoThemeData(
    primaryColor: Consts.primaryColor,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: 'Poppins',
        color: CupertinoColors.white,
      ),
    ),
    brightness: Brightness.dark,
  );
}
