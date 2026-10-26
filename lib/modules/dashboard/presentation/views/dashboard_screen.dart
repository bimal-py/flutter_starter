import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/dashboard/presentation/bloc/bloc.dart';
import 'package:flutter_starter/modules/dashboard/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/dashboard/utils/constants/constants.dart';

/// The app shell: the tab cubit, then [DashboardView].
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavigationCubit(),
      child: const DashboardView(),
    );
  }
}

/// Tabs over a bottom bar. Android back returns to the first tab, then needs
/// a second press within two seconds to leave the app.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const _exitWindow = Duration(seconds: 2);

  DateTime? _lastBackPressed;

  Future<void> _onBack() async {
    final cubit = context.read<BottomNavigationCubit>();
    if (cubit.state.currentIndex != 0) {
      cubit.changePage(0);
      return;
    }
    final now = DateTime.now();
    final last = _lastBackPressed;
    if (last == null || now.difference(last) > _exitWindow) {
      _lastBackPressed = now;
      CustomSnackbar.show(
        type: ToastType.info,
        message: DashboardStrings.pressBackAgainToExit,
      );
      return;
    }
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: BlocBuilder<BottomNavigationCubit, BottomNavigationState>(
        builder: (context, state) => Scaffold(
          body: SafeArea(child: DashboardBody(index: state.currentIndex)),
          bottomNavigationBar: DashboardNavBar(
            index: state.currentIndex,
            onSelect: context.read<BottomNavigationCubit>().changePage,
          ),
        ),
      ),
    );
  }
}
