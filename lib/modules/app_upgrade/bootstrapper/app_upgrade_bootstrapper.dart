import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/router/app_router.dart';
import 'package:flutter_starter/core/router/routes.dart';
import 'package:flutter_starter/modules/app_upgrade/cubit/app_upgrade_cubit.dart';
import 'package:flutter_starter/modules/app_upgrade/presentation/widgets/update_app_popup_widget.dart';

/// Wraps the app shell, kicks off [AppUpgradeCubit.checkForUpdate] after the
/// first frame, and pushes the update dialog onto the root navigator's
/// overlay once an update is detected. Suppressed on the splash route.
/// Shows at most once per launch.
class AppUpgradeBootstrapper extends StatefulWidget {
  const AppUpgradeBootstrapper({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpgradeBootstrapper> createState() => _AppUpgradeBootstrapperState();
}

class _AppUpgradeBootstrapperState extends State<AppUpgradeBootstrapper> {
  static bool _hasShown = false;
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    router.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _kicked = true;
      context.read<AppUpgradeCubit>().checkForUpdate();
      _maybeShow();
    });
  }

  @override
  void dispose() {
    router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() => _maybeShow();

  bool get _isOnSplash {
    final matches = router.routerDelegate.currentConfiguration.matches;
    if (matches.isEmpty) return true;
    return matches.last.matchedLocation == Routes.splash.path;
  }

  void _maybeShow() {
    if (_hasShown || !_kicked || _isOnSplash) return;

    final cubit = context.read<AppUpgradeCubit>();
    final s = cubit.state;
    if (!s.status.isUpdateAvailable) return;
    final message = s.updateMessage;
    if (message == null || message.isEmpty) return;

    _hasShown = true;
    // Defer one frame so the destination route finishes its build before
    // showDialog pushes onto its navigator.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = navigatorKey.currentState;
      final overlayContext =
          navState?.overlay?.context ?? navigatorKey.currentContext;
      if (overlayContext == null) return;
      showDialog<void>(
        context: overlayContext,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.7),
        useSafeArea: true,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: UpdateAppPopupWidget(content: message),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppUpgradeCubit, AppUpgradeState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (_, _) => _maybeShow(),
      child: widget.child,
    );
  }
}
