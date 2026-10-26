/// Single source of truth for app routes. Add a new entry here, then register
/// the [GoRoute] in `app_router.dart`.
///
/// Each entry goes with its module: remove it with the module's folder.
enum Routes {
  splash(name: 'splash', path: '/'), // onboarding
  onboarding(name: 'onboarding', path: '/onboarding'), // onboarding
  login(name: 'login', path: '/login'), // auth
  dashboard(name: 'dashboard', path: '/dashboard'), // dashboard
  settings(name: 'settings', path: 'settings'), // settings
  themePlayground(
    name: 'theme-playground',
    path: 'theme-playground',
  ), // settings
  about(name: 'about', path: 'about'), // about
  websiteView(name: 'website-view', path: 'website-view'); // website_view

  const Routes({required this.name, required this.path});

  final String name;
  final String path;
}
