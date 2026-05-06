/// Single source of truth for app routes. Add a new entry here, then register
/// the [GoRoute] in `app_router.dart`.
enum Routes {
  splash(name: 'splash', path: '/'),
  onboarding(name: 'onboarding', path: '/onboarding'),
  dashboard(name: 'dashboard', path: '/dashboard'),
  settings(name: 'settings', path: 'settings'),
  deviceInfo(name: 'device-info', path: 'device-info'),
  packageInfo(name: 'package-info', path: 'package-info'),
  websiteView(name: 'website-view', path: 'website-view');

  const Routes({required this.name, required this.path});

  final String name;
  final String path;
}
