import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum EditProfileFocus { name, phone }

class EditProfileScreen extends StatefulWidget {
  final EditProfileFocus? initialFocus;
  const EditProfileScreen({super.key, this.initialFocus});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name = TextEditingController(text: 'Faisal Al-Said');
  late final TextEditingController _phone = TextEditingController(text: '+968 9123 4567');
  late final FocusNode _nameFocus = FocusNode();
  late final FocusNode _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialFocus == EditProfileFocus.phone) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _phoneFocus.requestFocus());
    } else if (widget.initialFocus == EditProfileFocus.name) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _nameFocus.requestFocus());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Information')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Full Name', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          TextField(controller: _name, focusNode: _nameFocus, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: AppSpacing.lg),
          Text('Omani Phone Number', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _phone,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48)),
            onPressed: _save,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
