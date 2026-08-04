import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/repositories/admin_user_repository.dart';

enum UserManagementStatus { initial, loading, loaded, error }
enum UserSortField { joinedDate, watchTime, fullName }

class AdminUserProvider extends ChangeNotifier {
  final AdminUserRepository _repository;

  AdminUserProvider(this._repository);

  UserManagementStatus _status = UserManagementStatus.initial;
  UserManagementStatus get status => _status;

  List<AdminUserEntity> _users = [];
  List<AdminUserEntity> get users => _users;

  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _filterBlockedOnly = false;
  bool get filterBlockedOnly => _filterBlockedOnly;

  UserSortField _sortField = UserSortField.joinedDate;
  UserSortField get sortField => _sortField;

  Future<void> fetchUsers({bool isRefresh = false}) async {
    if (isRefresh) {
      _users = [];
      _lastDoc = null;
      _hasMore = true;
    }

    if (!_hasMore && !isRefresh) return;
    if (_status == UserManagementStatus.loading) return;
    
    _status = UserManagementStatus.loading;
    notifyListeners();

    final result = await _repository.getUsers(limit: 20, lastDoc: _lastDoc);

    if (result.isSuccess) {
      final page = result.data!;
      if (page.users.length < 20) {
        _hasMore = false;
      }
      _users.addAll(page.users);
      _lastDoc = page.lastDoc;
      _status = UserManagementStatus.loaded;
    } else {
      _errorMessage = result.failure.message;
      _status = UserManagementStatus.error;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleBlockedFilter(bool value) {
    _filterBlockedOnly = value;
    notifyListeners();
  }

  void setSortField(UserSortField field) {
    _sortField = field;
    _sortUsers();
    notifyListeners();
  }

  void _sortUsers() {
    switch (_sortField) {
      case UserSortField.joinedDate:
        _users.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Error in entity field name, using createdAt
        break;
      case UserSortField.watchTime:
        _users.sort((a, b) => b.watchTimeMinutes.compareTo(a.watchTimeMinutes));
        break;
      case UserSortField.fullName:
        _users.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
    }
  }

  List<AdminUserEntity> get filteredUsers {
    var filtered = _users.where((user) {
      final matchesSearch = user.email.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBlocked = !_filterBlockedOnly || user.isBlocked;
      
      return matchesSearch && matchesBlocked;
    }).toList();

    // Re-apply sorting to the filtered list
    switch (_sortField) {
      case UserSortField.joinedDate:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case UserSortField.watchTime:
        filtered.sort((a, b) => b.watchTimeMinutes.compareTo(a.watchTimeMinutes));
        break;
      case UserSortField.fullName:
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
    }
    
    return filtered;
  }

  Future<void> blockUser(String uid, bool block) async {
    final result = await _repository.updateUserStatus(uid, isBlocked: block);
    if (result.isSuccess) {
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isBlocked: block);
        notifyListeners();
      }
    }
  }

  Future<void> deleteUser(String uid) async {
    final result = await _repository.deleteUser(uid);
    if (result.isSuccess) {
      _users.removeWhere((u) => u.uid == uid);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getUserLibrary(String uid) async {
    final result = await _repository.getUserLibrary(uid);
    return result.isSuccess ? result.data : null;
  }
}
