import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/level_system.dart';

class MilestonesScreen extends StatelessWidget {
  final int currentStreakDays;

  const MilestonesScreen({super.key, required this.currentStreakDays});

  @override
  Widget build(BuildContext context) {
    final currentLevel = LevelSystem.getCurrentLevel(currentStreakDays);
    
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("MILESTONES", 
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1
          )),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: LevelSystem.levels.length,
        itemBuilder: (context, index) {
          final level = LevelSystem.levels[index];
          final int levelDays = level['days'];
          final String title = level['title'];
          final Color color = level['color'];
          
          // Determine status
          final bool isUnlocked = currentStreakDays >= levelDays;
          final bool isCurrent = currentLevel['title'] == title;
          final bool isNext = !isUnlocked && (index > 0 && currentStreakDays >= LevelSystem.levels[index-1]['days']);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isCurrent 
                  ? color.withOpacity(0.1) 
                  : const Color(0xFF111111),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrent 
                    ? color 
                    : (isUnlocked ? Colors.white.withOpacity(0.1) : Colors.transparent),
                width: isCurrent ? 2 : 1
              ),
            ),
            child: Row(
              children: [
                // Left: Status Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isUnlocked ? color.withOpacity(0.2) : const Color(0xFF222222),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrent ? Icons.my_location : (isUnlocked ? Icons.check : Icons.lock),
                    color: isUnlocked ? color : Colors.grey[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                
                // Middle: Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, 
                        style: GoogleFonts.spaceGrotesk(
                          color: isUnlocked ? Colors.white : Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5
                        )),
                      const SizedBox(height: 4),
                      Text("$levelDays DAYS STREAK", 
                        style: TextStyle(
                          color: isUnlocked ? color.withOpacity(0.8) : Colors.grey[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                        )),
                    ],
                  ),
                ),

                // Right: "YOU ARE HERE" badge or nothing
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("CURRENT", 
                      style: TextStyle(
                        color: Colors.black, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold
                      )),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.1, duration: 1000.ms)
              ],
            ),
          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
