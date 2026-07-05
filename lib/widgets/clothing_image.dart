import 'package:flutter/material.dart';

Widget clothingImage(
  String source, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  final fallback = errorBuilder ??
      (_, __, ___) => Icon(Icons.checkroom, size: width ?? 48);
  if (source.startsWith('http')) {
    return Image.network(source, width: width, height: height, fit: fit, errorBuilder: fallback);
  }
  return Image.asset(source, width: width, height: height, fit: fit, errorBuilder: fallback);
}