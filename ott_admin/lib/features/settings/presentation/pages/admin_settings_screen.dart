import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _maintenanceMode = false;
  final _appNameController = TextEditingController(text: 'EpicStream');
  final _supportEmailController = TextEditingController(text: 'support@epicstream.com');

  @override
  void dispose() {
    _appNameController.dispose();
    _supportEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Global App Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'General Configuration',
              children: [
                _buildTextField('App Name', _appNameController),
                const SizedBox(height: 24),
                _buildTextField('Support Email', _supportEmailController),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Platform Status',
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Maintenance Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('When enabled, mobile users will see a maintenance screen and won\'t be able to stream.'),
                  value: _maintenanceMode,
                  activeColor: AdminColors.primary,
                  onChanged: (val) => setState(() => _maintenanceMode = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Legal & Compliance',
              children: [
                _buildLinkTile('Edit Privacy Policy', Icons.privacy_tip_outlined),
                _buildLinkTile('Edit Terms & Conditions', Icons.description_outlined),
                _buildLinkTile('Manage FAQ Content', Icons.help_outline),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved successfully.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AdminColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
      ),
    );
  }

  Widget _buildLinkTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white38),
      title: Text(title),
      trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.white24),
      contentPadding: EdgeInsets.zero,
      onTap: () {},
    );
  }
}
