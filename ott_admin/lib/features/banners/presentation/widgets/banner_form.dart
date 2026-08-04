import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/admin_banner_entity.dart';
import '../providers/banner_provider.dart';
import '../../../movies/presentation/widgets/image_picker_widget.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';

class BannerForm extends StatefulWidget {
  final AdminBannerEntity? banner;
  final VoidCallback onSaved;

  const BannerForm({super.key, this.banner, required this.onSaved});

  @override
  State<BannerForm> createState() => _BannerFormState();
}

class _BannerFormState extends State<BannerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _targetValueController;
  
  BannerType _type = BannerType.home;
  BannerStatus _status = BannerStatus.draft;
  BannerTargetType _targetType = BannerTargetType.movie;
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  dynamic _mobileFile;
  dynamic _tabletFile;
  dynamic _desktopFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _descController = TextEditingController(text: widget.banner?.description ?? '');
    _targetValueController = TextEditingController(text: widget.banner?.targetValue ?? '');
    _type = widget.banner?.type ?? BannerType.home;
    _status = widget.banner?.status ?? BannerStatus.draft;
    _targetType = widget.banner?.targetType ?? BannerTargetType.movie;
    _startDate = widget.banner?.startDate ?? DateTime.now();
    _endDate = widget.banner?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final banner = AdminBannerEntity(
        id: widget.banner?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        mobileImageUrl: widget.banner?.mobileImageUrl ?? '',
        tabletImageUrl: widget.banner?.tabletImageUrl ?? '',
        desktopImageUrl: widget.banner?.desktopImageUrl ?? '',
        type: _type,
        status: _status,
        targetType: _targetType,
        targetValue: _targetValueController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        priority: widget.banner?.priority ?? 0,
      );

      if (widget.banner == null) {
        context.read<AdminBannerProvider>().addBanner(banner);
      } else {
        context.read<AdminBannerProvider>().updateBanner(banner);
      }
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
              decoration: const InputDecoration(labelText: 'Banner Title', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Image Pickers
            Row(
              children: [
                Expanded(
                  child: ImagePickerWidget(
                    label: 'Mobile (2:3 or 1:1)',
                    initialUrl: widget.banner?.mobileImageUrl,
                    aspectRatio: 1,
                    onImageSelected: (file) => _mobileFile = file,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ImagePickerWidget(
                    label: 'Tablet (16:9)',
                    initialUrl: widget.banner?.tabletImageUrl,
                    aspectRatio: 16 / 9,
                    onImageSelected: (file) => _tabletFile = file,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ImagePickerWidget(
                    label: 'Desktop (21:9)',
                    initialUrl: widget.banner?.desktopImageUrl,
                    aspectRatio: 21 / 9,
                    onImageSelected: (file) => _desktopFile = file,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<BannerType>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Banner Type', border: OutlineInputBorder()),
                    items: BannerType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<BannerStatus>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: BannerStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<BannerTargetType>(
                    value: _targetType,
                    decoration: const InputDecoration(labelText: 'Target Type', border: OutlineInputBorder()),
                    items: BannerTargetType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                    onChanged: (val) => setState(() => _targetType = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _targetValueController,
                    decoration: InputDecoration(
                      labelText: _targetType == BannerTargetType.url ? 'URL' : 'Movie/Category ID',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(_startDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                    shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(_endDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                    shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
                child: const Text('SAVE BANNER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
