import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../providers/admin_notification_provider.dart';
import '../../../../core/theme/admin_colors.dart';

class NotificationForm extends StatefulWidget {
  final VoidCallback onSaved;

  const NotificationForm({super.key, required this.onSaved});

  @override
  State<NotificationForm> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _imageUrlController;
  late TextEditingController _targetValueController;
  late TextEditingController _deepLinkValueController;

  AdminNotificationType _type = AdminNotificationType.movieRelease;
  AdminNotificationTarget _target = AdminNotificationTarget.all;
  AdminNotificationScheduleType _scheduleType = AdminNotificationScheduleType.immediate;
  String? _deepLinkType;
  DateTime? _scheduledFor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _imageUrlController = TextEditingController();
    _targetValueController = TextEditingController();
    _deepLinkValueController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    _targetValueController.dispose();
    _deepLinkValueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final notification = AdminNotificationEntity(
        id: '',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text.trim() : null,
        type: _type,
        target: _target,
        targetValues: _targetValueController.text.isNotEmpty 
            ? _targetValueController.text.split(',').map((e) => e.trim()).toList() 
            : null,
        scheduleType: _scheduleType,
        scheduledFor: _scheduledFor,
        deepLinkType: _deepLinkType,
        deepLinkValue: _deepLinkValueController.text.isNotEmpty ? _deepLinkValueController.text.trim() : null,
        createdAt: DateTime.now(),
      );

      context.read<AdminNotificationProvider>().sendNotification(notification);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Notification Title', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Message Body', border: OutlineInputBorder()),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text('Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<AdminNotificationType>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                    items: AdminNotificationType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<AdminNotificationTarget>(
                    value: _target,
                    decoration: const InputDecoration(labelText: 'Target Audience', border: OutlineInputBorder()),
                    items: AdminNotificationTarget.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                    onChanged: (val) => setState(() => _target = val!),
                  ),
                ),
              ],
            ),
            if (_target == AdminNotificationTarget.selected || _target == AdminNotificationTarget.language || _target == AdminNotificationTarget.country) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetValueController,
                decoration: InputDecoration(
                  labelText: _target == AdminNotificationTarget.selected ? 'User IDs (comma separated)' : 'Codes (comma separated)',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required for this target' : null,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<AdminNotificationScheduleType>(
                    value: _scheduleType,
                    decoration: const InputDecoration(labelText: 'Schedule', border: OutlineInputBorder()),
                    items: AdminNotificationScheduleType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                    onChanged: (val) => setState(() => _scheduleType = val!),
                  ),
                ),
                if (_scheduleType == AdminNotificationScheduleType.scheduled) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTile(
                      title: const Text('Date'),
                      subtitle: Text(_scheduledFor?.toString().split(' ')[0] ?? 'Select Date'),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => _scheduledFor = date);
                      },
                      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            const Text('Deep Linking (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _deepLinkType,
                    decoration: const InputDecoration(labelText: 'Link Type', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('None')),
                      DropdownMenuItem(value: 'movie', child: Text('Movie')),
                      DropdownMenuItem(value: 'category', child: Text('Category')),
                    ],
                    onChanged: (val) => setState(() => _deepLinkType = val),
                  ),
                ),
                if (_deepLinkType != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _deepLinkValueController,
                      decoration: const InputDecoration(labelText: 'Target ID', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required for deep link' : null,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
                child: const Text('SEND NOTIFICATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
