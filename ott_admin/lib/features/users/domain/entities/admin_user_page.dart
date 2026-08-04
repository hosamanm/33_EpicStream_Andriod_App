import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_user_entity.dart';

class AdminUserPage {
  final List<AdminUserEntity> users;
  final DocumentSnapshot? lastDoc;

  const AdminUserPage({required this.users, this.lastDoc});
}
