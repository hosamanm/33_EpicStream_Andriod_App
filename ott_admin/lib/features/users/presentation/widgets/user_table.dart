import 'package:flutter/material.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../controllers/admin_user_controller.dart';

class UserTable extends StatelessWidget {
  final List<AdminUserEntity> users;
  final AdminUserController controller;

  const UserTable({
    super.key,
    required this.users,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 24,
      headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
      columns: const [
        DataColumn(label: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Watch Time', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Devices', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Joined', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: users.map((user) {
        return DataRow(cells: [
          DataCell(Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
                child: user.profileImage == null ? const Icon(Icons.person, size: 16) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.white38)),
                ],
              ),
            ],
          )),
          DataCell(_StatusBadge(isBlocked: user.isBlocked)),
          DataCell(Text('${user.watchTimeMinutes} min')),
          DataCell(Text(user.deviceCount.toString())),
          DataCell(Text(user.createdAt.toString().split(' ')[0])),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 20, color: Colors.blueAccent),
                onPressed: () => controller.onViewUser(context, user),
              ),
              IconButton(
                icon: Icon(
                  user.isBlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  size: 20,
                  color: user.isBlocked ? Colors.greenAccent : Colors.orangeAccent,
                ),
                onPressed: () => controller.onBlockToggle(user),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                onPressed: () => controller.onDeleteUser(context, user.uid),
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isBlocked;
  const _StatusBadge({required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    final color = isBlocked ? Colors.redAccent : Colors.greenAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        isBlocked ? 'BLOCKED' : 'ACTIVE',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
