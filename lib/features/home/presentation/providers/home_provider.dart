import 'package:flutter/material.dart';
import '../../domain/entities/media_item.dart';
import 'home_state.dart';

class HomeProvider extends ChangeNotifier {
  HomeState _state = HomeInitial();
  HomeState get state => _state;

  void setState(HomeState state) {
    _state = state;
    notifyListeners();
  }

  // Helper to get loaded state data safely
  HomeLoaded? get loadedState => _state is HomeLoaded ? _state as HomeLoaded : null;
}
