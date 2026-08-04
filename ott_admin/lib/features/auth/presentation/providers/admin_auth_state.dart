import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entity.dart';

enum AdminAuthStatus { initial, loading, authenticated, unauthenticated, unauthorized, error }

class AdminAuthState extends Equatable {
  final AdminAuthStatus status;
  final AdminEntity? admin;
  final String? errorMessage;

  const AdminAuthState({
    this.status = AdminAuthStatus.initial,
    this.admin,
    this.errorMessage,
  });

  factory AdminAuthState.initial() => const AdminAuthState();
  factory AdminAuthState.loading() => const AdminAuthState(status: AdminAuthStatus.loading);
  factory AdminAuthState.authenticated(AdminEntity admin) => AdminAuthState(status: AdminAuthStatus.authenticated, admin: admin);
  factory AdminAuthState.unauthenticated() => const AdminAuthState(status: AdminAuthStatus.unauthenticated);
  factory AdminAuthState.unauthorized() => const AdminAuthState(status: AdminAuthStatus.unauthorized);
  factory AdminAuthState.error(String message) => AdminAuthState(status: AdminAuthStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, admin, errorMessage];
}
