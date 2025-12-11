import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/relapse_viewmodel.dart';
import '../../../core/constants/constants.dart';

/// Relapse analysis bottom sheet.
class RelapseSheet extends ConsumerStatefulWidget {
  final Future<void> Function() onRelapseComplete;

  const RelapseSheet({required this.onRelapseComplete, super.key});

  @override
  ConsumerState<RelapseSheet> createState() => _RelapseSheetState();
}

class _RelapseSheetState extends ConsumerState<RelapseSheet> {
  String? _selectedTrigger;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _otherTriggerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    _otherTriggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.resetAnalysis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dangerRed,
                ),
              ),
              Text(
                AppStrings.beHonest,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Trigger Selection
              Text(
                AppStrings.whatTriggered,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppStrings.triggerOptions.map((trigger) {
                  final isSelected = _selectedTrigger == trigger;
                  return ChoiceChip(
                    label: Text(trigger),
                    selected: isSelected,
                    onSelected: (val) =>
                        setState(() => _selectedTrigger = val ? trigger : null),
                    backgroundColor: AppColors.cardBackgroundLight,
                    selectedColor: AppColors.dangerRed,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Custom Trigger
              if (_selectedTrigger == 'Other') ...[
                _buildTextField(
                  controller: _otherTriggerController,
                  label: 'Specify Trigger',
                  hint: 'What was the specific trigger?',
                ),
                const SizedBox(height: 20),
              ],

              // Location
              _buildTextField(
                controller: _locationController,
                label: AppStrings.whereWereYou,
                hint: 'e.g. Home, Office...',
              ),
              const SizedBox(height: 20),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: AppStrings.whatHappened,
                hint: 'Brief note...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _canSubmit ? _submit : null,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          AppStrings.resetCounter,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canSubmit =>
      !_isSubmitting &&
      _selectedTrigger != null &&
      (_selectedTrigger != 'Other' || _otherTriggerController.text.isNotEmpty);

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackgroundLight,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[700]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final actualTrigger = _selectedTrigger == 'Other'
        ? _otherTriggerController.text
        : _selectedTrigger!;

    await ref
        .read(relapseViewmodelProvider.notifier)
        .logRelapse(
          trigger: actualTrigger,
          location: _locationController.text,
          notes: _notesController.text,
        );

    await Future.delayed(const Duration(milliseconds: 150));
    await widget.onRelapseComplete();

    if (mounted) Navigator.pop(context);
  }
}
