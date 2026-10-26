import 'package:flutter/material.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/common/common.dart';

class StarterApp extends StatelessWidget {
  const StarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingOverlayWidget(
      child: GlobalBlocConfig(child: StarterAppView()),
    );
  }
}
