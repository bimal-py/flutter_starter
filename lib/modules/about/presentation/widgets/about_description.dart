import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

class AboutDescription extends StatelessWidget {
  const AboutDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Text(
          AppConstants.aboutAppText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
