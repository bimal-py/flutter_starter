import 'package:equatable/equatable.dart';

class AppUpgradeInfoEntity extends Equatable {
  const AppUpgradeInfoEntity({
    required this.latestVersion,
    required this.currentVersion,
    required this.isForceUpdate,
    this.updateMessage,
  });

  final String latestVersion;
  final String currentVersion;
  final bool isForceUpdate;
  final String? updateMessage;

  bool get requiresUpdate {
    try {
      final c = currentVersion.split('.').map(int.parse).toList();
      final t = latestVersion.split('.').map(int.parse).toList();
      final len = c.length > t.length ? c.length : t.length;
      for (var i = 0; i < len; i++) {
        final cv = i < c.length ? c[i] : 0;
        final tv = i < t.length ? t[i] : 0;
        if (cv < tv) return true;
        if (cv > tv) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  List<Object?> get props => [
    latestVersion,
    currentVersion,
    isForceUpdate,
    updateMessage,
  ];
}
