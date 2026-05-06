import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/dashboard/dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavigationCubit(),
      child: const DashboardScreenView(),
    );
  }
}

class DashboardScreenView extends StatefulWidget {
  const DashboardScreenView({super.key});

  @override
  State<DashboardScreenView> createState() => _DashboardScreenViewState();
}

class _DashboardScreenViewState extends State<DashboardScreenView> {
  final PageController _pageController = PageController(initialPage: 0);
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    context.read<BottomNavigationCubit>().changePage(
      _pageController.initialPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final isFirstTab = (_pageController.page ?? 0) == 0;
        if (isFirstTab) {
          final now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
            _lastBackPressed = now;
            CustomSnackbar.show(
              type: ToastType.info,
              message: 'Press back again to exit',
            );
            return;
          }
          await SystemNavigator.pop();
        } else {
          context.read<BottomNavigationCubit>().changePage(0);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: DashboardBodyWidget(pageController: _pageController),
        ),
        bottomNavigationBar: DashboardNavbarWidget(
          pageController: _pageController,
        ),
      ),
    );
  }
}
