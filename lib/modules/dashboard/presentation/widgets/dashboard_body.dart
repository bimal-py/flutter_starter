import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/dashboard/presentation/cubit/cubit.dart';
import 'package:flutter_starter/modules/home/home.dart';
import 'package:flutter_starter/modules/settings/settings.dart';

class DashboardBodyWidget extends StatelessWidget {
  const DashboardBodyWidget({super.key, required PageController pageController})
    : _pageController = pageController;

  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: (index) =>
          context.read<BottomNavigationCubit>().changePage(index),
      children: const [
        HomeScreen(),
        SettingsScreen(),
      ],
    );
  }
}
