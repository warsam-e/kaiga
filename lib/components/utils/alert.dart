import 'package:flutter_platform_alert/flutter_platform_alert.dart';

/// Shows an alert with a title and optional content.
Future<AlertButton> showAlert({
  required String title,
  String? content,
}) =>
    FlutterPlatformAlert.showAlert(
      windowTitle: title,
      text: content ?? '',
      alertStyle: AlertButtonStyle.ok,
      iconStyle: IconStyle.information,
    );

/// Shows an alert with a title and optional content, with a confirm and cancel button.
Future<bool> showConfirmAlert({
  required String title,
  String? content,
  bool destructive = true,
}) async {
  final res = await FlutterPlatformAlert.showCustomAlert(
    windowTitle: title,
    text: content ?? '',
    iconStyle: IconStyle.warning,
    positiveButtonTitle: 'Yes',
    negativeButtonTitle: 'No',
    options: PlatformAlertOptions(
      ios: IosAlertOptions(
        positiveButtonStyle: destructive ? IosButtonStyle.destructive : null,
        negativeButtonStyle: IosButtonStyle.cancel,
      ),
    ),
  );

  return res == CustomButton.positiveButton;
}
