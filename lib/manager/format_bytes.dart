import 'dart:math';

String formatBytes(double bytes, [int decimals = 2]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  int i = (bytes == 0) ? 0 : (log(bytes) / log(1024)).floor();
  double size = bytes / pow(1024, i);
  return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
}
