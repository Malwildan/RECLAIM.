import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildAnimatedText(
                      "From us,\nFor us,\nBy us.",
                      delay: 500.ms,
                      hold: 2000.ms,
                    ),
                    _buildAnimatedText(
                      "Developed with\nempathy.",
                      delay: 3500.ms,
                      hold: 2000.ms,
                    ),
                    _buildFinalLogo(delay: 6500.ms),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                    "Tap anywhere to close",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(duration: 1200.ms, begin: 0.2, end: 1.0)
                  .animate()
                  .fadeIn(delay: 7000.ms, duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(
    String text, {
    required Duration delay,
    required Duration hold,
  }) {
    return Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        )
        .animate()
        .fadeIn(delay: delay, duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 600.ms)
        .then(delay: hold)
        .fadeOut(duration: 600.ms)
        .slideY(begin: 0, end: -0.1, duration: 600.ms);
  }

  Widget _buildFinalLogo({required Duration delay}) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "RECLAIM.",
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.accentGreen,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "v0.1.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: delay, duration: 800.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}
