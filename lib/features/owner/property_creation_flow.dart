import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aqarati_button.dart';
import '../../data/models/enums.dart';
import '../../data/models/money.dart';
import '../../data/models/property.dart';
import '../../data/models/property_verification.dart';
import 'owner_state.dart';

enum _Step { transaction, type, location, basics, details, media, preview, submitted }

class PropertyCreationFlow extends ConsumerStatefulWidget {
  const PropertyCreationFlow({super.key});

  @override
  ConsumerState<PropertyCreationFlow> createState() => _PropertyCreationFlowState();
}

class _PropertyCreationFlowState extends ConsumerState<PropertyCreationFlow> {
  _Step _step = _Step.transaction;
  static const _order = _Step.values;

  TransactionType? _transactionType;
  PropertyType? _propertyType;
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<Uint8List> _photos = [];
  bool _photosLoading = false;
  String? _titleDeedFileName;
  bool _titleDeedLoading = false;

  Future<void> _addPhotos() async {
    setState(() => _photosLoading = true);
    try {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
      for (final file in picked) {
        _photos.add(await file.readAsBytes());
      }
    } catch (_) {
      // User cancelled the picker, or the platform declined — nothing to add.
    } finally {
      if (mounted) setState(() => _photosLoading = false);
    }
  }

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  void _setCoverPhoto(int index) => setState(() {
        final cover = _photos.removeAt(index);
        _photos.insert(0, cover);
      });

  Future<void> _pickTitleDeed() async {
    setState(() => _titleDeedLoading = true);
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file != null) {
        _titleDeedFileName = file.name;
      }
    } catch (_) {
      // Cancelled or declined.
    } finally {
      if (mounted) setState(() => _titleDeedLoading = false);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _next() {
    final i = _order.indexOf(_step);
    if (i < _order.length - 1) setState(() => _step = _order[i + 1]);
  }

  void _back() {
    final i = _order.indexOf(_step);
    if (i > 0) setState(() => _step = _order[i - 1]);
  }

  void _submit() {
    final property = Property(
      id: 'owner_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim().isEmpty ? 'Untitled listing' : _titleController.text.trim(),
      locationLabel: _locationController.text.trim(),
      area: _locationController.text.trim(),
      type: _propertyType ?? PropertyType.apartment,
      transactionType: _transactionType ?? TransactionType.buy,
      price: Money(double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0),
      bedrooms: int.tryParse(_bedroomsController.text),
      bathrooms: int.tryParse(_bathroomsController.text),
      areaSqm: double.tryParse(_areaController.text) ?? 0,
      verification: const PropertyVerification(status: VerificationStatus.submitted),
      listedByBusinessId: '',
      description: _descriptionController.text.trim(),
    );
    ref.read(ownerListingsProvider.notifier).update((state) => [...state, property]);
    setState(() => _step = _Step.submitted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List a Property')),
      body: SafeArea(child: _buildStep()),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.transaction:
        return _StepScaffold(
          title: 'Transaction',
          subtitle: 'What are you listing this property for?',
          canContinue: _transactionType != null,
          onBack: null,
          onContinue: _next,
          child: Column(
            children: TransactionType.values
                .map((t) => _OptionTile(
                      label: t.label,
                      selected: _transactionType == t,
                      onTap: () => setState(() => _transactionType = t),
                    ))
                .toList(),
          ),
        );
      case _Step.type:
        return _StepScaffold(
          title: 'Property type',
          subtitle: 'Choose the category that best fits.',
          canContinue: _propertyType != null,
          onBack: _back,
          onContinue: _next,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: PropertyType.values
                .map((t) => ChoiceChip(
                      label: Text(t.label),
                      selected: _propertyType == t,
                      onSelected: (_) => setState(() => _propertyType = t),
                    ))
                .toList(),
          ),
        );
      case _Step.location:
        return _StepScaffold(
          title: 'Location',
          subtitle: 'Where is this property located?',
          canContinue: _locationController.text.trim().isNotEmpty,
          onBack: _back,
          onContinue: _next,
          child: TextField(
            controller: _locationController,
            decoration: const InputDecoration(hintText: 'e.g. Al Mouj, Muscat, Oman'),
            onChanged: (_) => setState(() {}),
          ),
        );
      case _Step.basics:
        return _StepScaffold(
          title: 'Basics',
          subtitle: 'Add the key facts buyers look for first.',
          canContinue: _priceController.text.trim().isNotEmpty && _areaController.text.trim().isNotEmpty,
          onBack: _back,
          onContinue: _next,
          child: Column(
            children: [
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (OMR)'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bedroomsController,
                      decoration: const InputDecoration(labelText: 'Bedrooms'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _bathroomsController,
                      decoration: const InputDecoration(labelText: 'Bathrooms'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Area (m²)'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        );
      case _Step.details:
        return _StepScaffold(
          title: 'Details',
          subtitle: 'Give this listing a title and description.',
          canContinue: _titleController.text.trim().isNotEmpty,
          onBack: _back,
          onContinue: _next,
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Listing title'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
            ],
          ),
        );
      case _Step.media:
        return _StepScaffold(
          title: 'Photos & documents',
          subtitle: 'Add photos and ownership documents (optional for now).',
          canContinue: true,
          onBack: _back,
          onContinue: _next,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Photos', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _PhotoUploadGrid(
                photos: _photos,
                loading: _photosLoading,
                onAdd: _addPhotos,
                onRemove: _removePhoto,
                onSetCover: _setCoverPhoto,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Title deed', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _DocumentUploadTile(
                fileName: _titleDeedFileName,
                loading: _titleDeedLoading,
                onPick: _pickTitleDeed,
                onRemove: () => setState(() => _titleDeedFileName = null),
              ),
            ],
          ),
        );
      case _Step.preview:
        return _StepScaffold(
          title: 'Preview',
          subtitle: 'This is how buyers will see your listing.',
          canContinue: true,
          onBack: _back,
          onContinue: _submit,
          continueLabel: 'Submit for review',
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text.trim().isEmpty ? 'Untitled listing' : _titleController.text.trim(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(_locationController.text.trim(), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'OMR ${_priceController.text.trim()}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _photos.isEmpty ? 'No photos added' : '${_photos.length} photo${_photos.length == 1 ? '' : 's'} added',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.slate),
                ),
                if (_titleDeedFileName != null)
                  Text('Title deed: $_titleDeedFileName', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.slate)),
              ],
            ),
          ),
        );
      case _Step.submitted:
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule_rounded, size: 72, color: AppColors.pending),
              const SizedBox(height: AppSpacing.xl),
              Text('Under review', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "We've received your listing. Our team is reviewing it before it goes live.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AqaratiButton(
                label: 'Go to Owner Dashboard',
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
    }
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool canContinue;
  final VoidCallback? onBack;
  final VoidCallback onContinue;
  final String continueLabel;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.canContinue,
    required this.onBack,
    required this.onContinue,
    this.continueLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              if (onBack != null) IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xl),
                child,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AqaratiButton(label: continueLabel, fullWidth: true, onPressed: canContinue ? onContinue : null),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Real photo grid — add/remove/set-cover all actually mutate state (no
/// backend to persist to yet, so photos live only for this session/draft).
class _PhotoUploadGrid extends StatelessWidget {
  final List<Uint8List> photos;
  final bool loading;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onSetCover;

  const _PhotoUploadGrid({
    required this.photos,
    required this.loading,
    required this.onAdd,
    required this.onRemove,
    required this.onSetCover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photos.isEmpty && !loading)
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.slate),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Add photos', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < photos.length; i++)
                _PhotoThumb(bytes: photos[i], isCover: i == 0, onRemove: () => onRemove(i), onSetCover: () => onSetCover(i)),
              if (loading)
                const SizedBox(width: 88, height: 88, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Icon(Icons.add_rounded, color: AppColors.slate),
                  ),
                ),
            ],
          ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text('Tap a photo to set it as the cover.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.slate)),
        ],
      ],
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final Uint8List bytes;
  final bool isCover;
  final VoidCallback onRemove;
  final VoidCallback onSetCover;

  const _PhotoThumb({required this.bytes, required this.isCover, required this.onRemove, required this.onSetCover});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSetCover,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.memory(bytes, fit: BoxFit.cover),
            ),
            if (isCover)
              Positioned(
                left: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                  child: Text('Cover', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
                ),
              ),
            Positioned(
              right: 2,
              top: 2,
              child: InkWell(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Real single-document picker for the title deed slot (image-only — no PDF
/// library is available in this project, so a photo of the document is what
/// this actually accepts, which is what the UI says).
class _DocumentUploadTile extends StatelessWidget {
  final String? fileName;
  final bool loading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _DocumentUploadTile({required this.fileName, required this.loading, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (fileName != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(fileName!, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
            IconButton(onPressed: onRemove, icon: const Icon(Icons.close_rounded)),
          ],
        ),
      );
    }
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Icon(Icons.upload_file_outlined, size: 32, color: AppColors.slate),
            const SizedBox(height: AppSpacing.sm),
            Text('Add title deed', style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
