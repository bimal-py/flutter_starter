import 'package:equatable/equatable.dart';

/// Result of asking the server to email a sign-up or password-reset code.
class VerificationCodeEntity extends Equatable {
  /// True when an unexpired code was already sent, so no new email went out.
  final bool? alreadySent;

  /// Seconds until the code expires; Resend unlocks then.
  final int? expiresIn;

  const VerificationCodeEntity({this.alreadySent, this.expiresIn});

  @override
  List<Object?> get props => [alreadySent, expiresIn];
}
