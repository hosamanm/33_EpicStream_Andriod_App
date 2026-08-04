import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../data/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  StreamSubscription? _subscription;

  UserProfileEntity? _profile;
  UserProfileEntity? get profile => _profile;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileProvider(this._profileService) {
    _init();
  }

  void _init() {
    _subscription = _profileService.watchProfile().listen((updatedProfile) {
      _profile = updatedProfile;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    });
  }

  Future<void> updateProfile(UserProfileEntity updatedProfile) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _profileService.updateProfile(updatedProfile);
      _profile = updatedProfile;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _profileService.logout();
  }

  Future<void> deleteAccount() async {
    await _profileService.deleteAccount();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
