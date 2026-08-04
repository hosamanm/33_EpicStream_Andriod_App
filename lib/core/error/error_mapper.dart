import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'failures.dart';

/// Centralized utility to map various framework/network exceptions 
/// into Domain-level Failure objects with user-friendly messages.
class ErrorMapper {
  static Failure map(dynamic error) {
    if (error is DioException) {
      return _mapDioError(error);
    } else if (error is FirebaseException) {
      return _mapFirebaseError(error);
    } else if (error is SocketException) {
      return const NetworkFailure('No internet connection detected. Please check your network settings.');
    }
    
    return ServerFailure(error.toString());
  }

  static Failure _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timed out. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) return const ServerFailure('Unauthorized: Please login again.');
        if (statusCode == 403) return const ServerFailure('Access denied: You do not have permission to view this content.');
        if (statusCode == 404) return const ServerFailure('Requested resource not found.');
        if (statusCode != null && statusCode >= 500) return const ServerFailure('Server is under maintenance. Please try later.');
        return ServerFailure('Unexpected server error ($statusCode)');
      default:
        return const NetworkFailure('Network communication failed. Check your connection.');
    }
  }

  static Failure _mapFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'user-not-found':
        return const ServerFailure('No account found with this email.');
      case 'wrong-password':
        return const ServerFailure('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return const ServerFailure('This email is already registered. Try logging in.');
      case 'weak-password':
        return const ServerFailure('Password is too weak. Please use at least 8 characters.');
      case 'invalid-credential':
        return const ServerFailure('Invalid credentials provided.');
      case 'network-request-failed':
        return const NetworkFailure('Connection to Firebase failed. Check your internet.');
      case 'requires-recent-login':
        return const ServerFailure('Security: Please log out and log in again to perform this sensitive action.');
      case 'permission-denied':
        return const ServerFailure('Permission denied: You do not have access to this data.');
      default:
        return ServerFailure(error.message ?? 'A database error occurred (${error.code})');
    }
  }
}
