import 'package:equatable/equatable.dart';

/// Empty params marker for use cases that take no input.
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => const [];
}
