import 'package:flutter/material.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/home/home.dart';
import 'package:flutter_starter/modules/settings/settings.dart';

/// One child per tab, in the nav bar's order. A tab is built on its first
/// visit and then kept alive, so switching back never reloads it.
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return LazyIndexedStack(
      index: index,
      children: const [HomeScreen(), SettingsScreen()],
    );
  }
}
