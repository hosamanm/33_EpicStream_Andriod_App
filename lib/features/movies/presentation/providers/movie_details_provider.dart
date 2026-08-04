import 'package:flutter/material.dart';
import 'movie_details_state.dart';

class MovieDetailsProvider extends ChangeNotifier {
  MovieDetailsState _state = MovieDetailsInitial();
  MovieDetailsState get state => _state;

  void setState(MovieDetailsState newState) {
    _state = newState;
    notifyListeners();
  }

  // Helpers to get data from loaded state
  MovieDetailsLoaded? get loadedState => _state is MovieDetailsLoaded ? _state as MovieDetailsLoaded : null;
}
