import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/providers.dart';
import '../../../core/constants/constants.dart';

/// Brain fact card widget with Gemini AI integration.
class BrainFactCard extends ConsumerStatefulWidget {
  const BrainFactCard({super.key});

  @override
  ConsumerState<BrainFactCard> createState() => _BrainFactCardState();
}

class _BrainFactCardState extends ConsumerState<BrainFactCard> {
  String _fact = 'Analyzing brain architecture...';
  String _source = 'AI Loading';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFact();
  }

  Future<void> _loadFact() async {
    setState(() {
      _isLoading = true;
      _fact = 'Analyzing brain architecture...';
    });

    final geminiService = ref.read(geminiServiceProvider);
    final data = await geminiService.getGenerativeBrainFact();

    if (mounted) {
      setState(() {
        _fact = data['fact']!;
        _source = data['source']!;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: AppColors.accentTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SYSTEM MESSAGE',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.accentTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey,
                  ),
                )
              else
                GestureDetector(
                  onTap: _loadFact,
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _fact,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SOURCE: $_source',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.05, end: 0);
  }
}
