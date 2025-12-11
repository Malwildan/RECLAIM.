import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showTopSnackBar(BuildContext context, String message, {
  Color? backgroundColor, 
  Color? textColor,
  Duration duration = const Duration(seconds: 3),
  IconData? icon,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: _TopSnackBarWidget(
          message: message,
          backgroundColor: backgroundColor ?? const Color(0xFF222222),
          textColor: textColor,
          duration: duration,
          icon: icon,
          onDismiss: () {
            overlayEntry.remove();
          },
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color? textColor;
  final Duration duration;
  final IconData? icon;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.message,
    required this.backgroundColor,
    this.textColor,
    required this.duration,
    this.icon,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon, 
                  color: widget.textColor ?? _getContrastColor(widget.backgroundColor), 
                  size: 20
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  widget.message,
                  style: GoogleFonts.spaceGrotesk(
                    color: widget.textColor ?? _getContrastColor(widget.backgroundColor),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getContrastColor(Color background) {
    // Calculate luminance to determine if background is light or dark
    final luminance = background.computeLuminance();
    // If background is dark, use white text; if light, use black text
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
