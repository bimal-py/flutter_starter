import 'package:equatable/equatable.dart';
import 'package:flutter_starter/common/common.dart';

part 'bottom_navigation_state.dart';

/// The selected dashboard tab.
class BottomNavigationCubit extends SafeCubit<BottomNavigationState> {
  BottomNavigationCubit() : super(const BottomNavigationState(currentIndex: 0));

  void changePage(int index) =>
      emit(BottomNavigationState(currentIndex: index));
}
