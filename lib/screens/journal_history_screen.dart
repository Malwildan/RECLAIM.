import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../reclaim_service.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  final ReclaimService _service = ReclaimService();
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    final data = await _service.getJournalHistory();
    if (mounted) {
      setState(() {
        _journals = data;
        _isLoading = false;
      });
    }
  }

  String _getMoodEmoji(int rating) {
    switch (rating) {
      case 1: return '💀';
      case 2: return '😐';
      case 3: return '🌊';
      case 4: return '🔋';
      case 5: return '⚡';
      default: return '📝';
    }
  }

  Color _getMoodColor(int rating) {
    switch (rating) {
      case 1: return const Color(0xFF444444);
      case 2: return const Color(0xFF666666);
      case 3: return const Color(0xFF888888);
      case 4: return const Color(0xFFB4F8C8);
      case 5: return const Color(0xFFB4F8C8);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("JOURNAL HISTORY", 
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1
          )),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB4F8C8)))
          : _journals.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.book_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("No logs yet.", style: GoogleFonts.spaceGrotesk(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _journals.length,
                  itemBuilder: (context, index) {
                    final journal = _journals[index];
                    final content = journal['content'] as String? ?? '';
                    final mood = journal['mood_rating'] as int? ?? 3;
                    final date = DateTime.parse(journal['created_at']).toLocal();
                    final formattedDate = DateFormat('MMM d, y • h:mm a').format(date);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getMoodColor(mood).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(_getMoodEmoji(mood), style: const TextStyle(fontSize: 20)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(formattedDate, 
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          if (content.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(content, 
                              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
                          ]
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                ),
    );
  }
}
