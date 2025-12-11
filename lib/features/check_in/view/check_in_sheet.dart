import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/check_in_viewmodel.dart';
import '../../../core/constants/constants.dart';

/// Daily check-in bottom sheet.
class CheckInSheet extends ConsumerStatefulWidget {
  const CheckInSheet({super.key});

  @override
  ConsumerState<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<CheckInSheet> {
  int _selectedMood = 3;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> moods = [
    {
      'label': 'Drained',
      'emoji': '💀',
      'val': 1,
      'color': const Color(0xFF444444),
    },
    {'label': 'Meh', 'emoji': '😐', 'val': 2, 'color': const Color(0xFF666666)},
    {
      'label': 'Okay',
      'emoji': '🌊',
      'val': 3,
      'color': const Color(0xFF888888),
    },
    {'label': 'Good', 'emoji': '🔋', 'val': 4, 'color': AppColors.accentGreen},
    {
      'label': 'Energetic',
      'emoji': '⚡',
      'val': 5,
      'color': AppColors.accentGreen,
    },
  ];

  @override
  void dispose() {
    _noteController.dispose();
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
              Center(
                child: Container(width: 40, height: 4, color: Colors.grey[800]),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.vibeCheck,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Mood Selector
              Row(
                children: moods.map((m) {
                  bool isSelected = _selectedMood == m['val'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMood = m['val']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? m['color']
                              : AppColors.cardBackgroundLight,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              m['emoji'],
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                m['label'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? ((m['val'] as int) > 3
                                            ? Colors.black
                                            : Colors.white)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Note Input
              TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  hintText: AppStrings.anythingOnMind,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          AppStrings.logIt,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    await ref
        .read(checkInViewmodelProvider.notifier)
        .logCheckIn(_selectedMood, _noteController.text);

    if (mounted) Navigator.pop(context, true);
  }
}
