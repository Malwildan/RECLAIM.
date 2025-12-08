import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'reclaim_service.dart';

// --- 1. THE MOOD CHECK-IN SHEET ---
class DailyCheckInSheet extends StatefulWidget {
  const DailyCheckInSheet({super.key});

  @override
  State<DailyCheckInSheet> createState() => _DailyCheckInSheetState();
}

class _DailyCheckInSheetState extends State<DailyCheckInSheet> {
  int _selectedMood = 3; // Default 'Neutral'
  final TextEditingController _noteController = TextEditingController();
  final ReclaimService _service = ReclaimService();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> moods = [
    {'label': 'Drained', 'emoji': '💀', 'val': 1, 'color': Color(0xFF444444)},
    {'label': 'Meh', 'emoji': '😐', 'val': 2, 'color': Color(0xFF666666)},
    {'label': 'Okay', 'emoji': '🌊', 'val': 3, 'color': Color(0xFF888888)},
    {'label': 'Good', 'emoji': '🔋', 'val': 4, 'color': Color(0xFFB4F8C8)},
    {'label': 'God Mode', 'emoji': '⚡', 'val': 5, 'color': Color(0xFFB4F8C8)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, color: Colors.grey[800]),
          ),
          const SizedBox(height: 20),
          Text("VIBE CHECK",
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 20),
          
          // MOOD SELECTOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((m) {
              bool isSelected = _selectedMood == m['val'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = m['val']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? m['color'] : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Text(m['emoji'], style: const TextStyle(fontSize: 24)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          
          // NOTE INPUT
          TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF222222),
              hintText: "Anything on your mind?",
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB4F8C8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isSubmitting ? null : () async {
                setState(() => _isSubmitting = true);
                await _service.logDailyCheckIn(_selectedMood, _noteController.text);
                if (mounted) Navigator.pop(context);
              },
              child: _isSubmitting 
                ? const CircularProgressIndicator(color: Colors.black)
                : Text("LOG IT", style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
          const SizedBox(height: 20), // Bottom padding for keyboard
        ],
      ),
    );
  }
}

// --- 2. THE RELAPSE ANALYSIS SHEET ---
class RelapseAnalysisSheet extends StatefulWidget {
  final Future<void> Function() onRelapseComplete;
  const RelapseAnalysisSheet({required this.onRelapseComplete, super.key});

  @override
  State<RelapseAnalysisSheet> createState() => _RelapseAnalysisSheetState();
}

class _RelapseAnalysisSheetState extends State<RelapseAnalysisSheet> {
  final ReclaimService _service = ReclaimService();
  String? _selectedTrigger;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _otherTriggerController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> triggers = [
    "Stress/Anxiety", "Boredom", "Social Media", "Loneliness", "Insomnia", "Accidental Exposure", "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24 // Handle keyboard
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text("RESET ANALYSIS",
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFFFF4B4B))),
          const Text("Be honest. Data beats addiction.",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),

          // 1. TRIGGER SELECTION (Chips)
          const Text("What triggered it?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: triggers.map((trigger) {
              final isSelected = _selectedTrigger == trigger;
              return ChoiceChip(
                label: Text(trigger),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedTrigger = val ? trigger : null),
                backgroundColor: const Color(0xFF222222),
                selectedColor: const Color(0xFFFF4B4B),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Custom Trigger Input
          if (_selectedTrigger == "Other") ...[
            _buildTextField(
              controller: _otherTriggerController,
              label: "Specify Trigger",
              hint: "What was the specific trigger?",
            ),
            const SizedBox(height: 20),
          ],

          // 2. LOCATION
          _buildTextField(
            controller: _locationController,
            label: "Where were you?",
            hint: "e.g. Home, Office...",
          ),
          const SizedBox(height: 20),

          // 3. NOTES
          _buildTextField(
            controller: _notesController,
            label: "What happened?",
            hint: "Brief note...",
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // SUBMIT
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B4B), // Red for danger/reset
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: (_isSubmitting || _selectedTrigger == null || (_selectedTrigger == "Other" && _otherTriggerController.text.isEmpty)) ? null : () async {
                setState(() => _isSubmitting = true);
                
                final actualTrigger = _selectedTrigger == "Other" 
                    ? _otherTriggerController.text 
                    : _selectedTrigger!;

                await _service.logRelapseDetailed(
                  trigger: actualTrigger,
                  location: _locationController.text,
                  notes: _notesController.text,
                );
                // Ensure dashboard re-fetches after DB trigger updates streak
                await Future.delayed(const Duration(milliseconds: 150));
                await widget.onRelapseComplete(); // Callback to refresh dashboard
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Streak reset. Starting again."))
                  );
                }
              },
              child: _isSubmitting 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text("RESET COUNTER", style: GoogleFonts.spaceGrotesk(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required String hint,
    int maxLines = 1
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF222222),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[700]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide.none
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: Color(0xFF333333), width: 1)
            ),
          ),
        ),
      ],
    );
  }
}