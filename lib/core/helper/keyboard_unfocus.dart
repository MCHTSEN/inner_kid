import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KeyboardFocus extends StatelessWidget {
  final Widget child;

  const KeyboardFocus({super.key, required this.child});

  factory KeyboardFocus.unFocus({required Widget child}) =>
      KeyboardFocus(child: child);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: child,
    );
  }
}

class KeyboardDismissOnTap extends ConsumerWidget {
  const KeyboardDismissOnTap({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
