import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double size;

  const Gap._(this.size, {super.key});

  static const Gap extraLow = Gap._(4.0);
  static const Gap low = Gap._(8.0);
  static const Gap medium = Gap._(12.0);
  static const Gap normal = Gap._(16.0);
  static const Gap high = Gap._(24.0);
  static const Gap extraHigh = Gap._(32.0);
  static const Gap extraExtraHigh = Gap._(40.0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size, width: size);
  }
}
