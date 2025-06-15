import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirstAnalysisPage extends ConsumerStatefulWidget {
  const FirstAnalysisPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstAnalysisPageState();
}

class _FirstAnalysisPageState extends ConsumerState<FirstAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text('Hello World!'),
        ],
      ),
    );
  }
}
