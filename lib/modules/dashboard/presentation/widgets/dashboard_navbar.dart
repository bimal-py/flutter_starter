import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/modules/dashboard/presentation/cubit/cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardNavbarWidget extends StatelessWidget {
  const DashboardNavbarWidget({
    super.key,
    required PageController pageController,
  }) : _pageController = pageController;

  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocConsumer<BottomNavigationCubit, BottomNavigationState>(
      listener: (context, state) =>
          _pageController.jumpToPage(state.currentIndex),
      builder: (context, state) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
            ),
          ),
          child: NavigationBar(
            selectedIndex: state.currentIndex,
            onDestinationSelected: (index) =>
                context.read<BottomNavigationCubit>().changePage(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.house),
                selectedIcon: Icon(LucideIcons.house),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.settings),
                selectedIcon: Icon(LucideIcons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
