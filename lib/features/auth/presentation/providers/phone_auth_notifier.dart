import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

enum PhoneAuthState { idle, sendingOtp, otpSent, verifying, success, error }

class PhoneAuthNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;

  PhoneAuthNotifier(this._authRepository);

  PhoneAuthState _state = PhoneAuthState.idle;
  PhoneAuthState get state => _state;

  String? _verificationId;
  String? get verificationId => _verificationId;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _resendToken;
  int? get resendToken => _resendToken;

  int _timerCount = 60;
  int get timerCount => _timerCount;
  Timer? _timer;

  void _setState(PhoneAuthState state) {
    _state = state;
    notifyListeners();
  }

  void _startTimer() {
    _timerCount = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerCount == 0) {
        timer.cancel();
      } else {
        _timerCount--;
        notifyListeners();
      }
    });
  }

  Future<void> sendOtp(String phoneNumber) async {
    _setState(PhoneAuthState.sendingOtp);
    _errorMessage = null;

    final result = await _authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _setState(PhoneAuthState.otpSent);
        _startTimer();
      },
      verificationFailed: (message) {
        _errorMessage = message;
        _setState(PhoneAuthState.error);
      },
    );

    if (result.isError) {
      _errorMessage = result.failure.message;
      _setState(PhoneAuthState.error);
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) return;
    
    _setState(PhoneAuthState.verifying);
    final result = await _authRepository.signInWithPhoneNumber(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    if (result.isSuccess) {
      _setState(PhoneAuthState.success);
    } else {
      _errorMessage = result.failure.message;
      _setState(PhoneAuthState.error);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
