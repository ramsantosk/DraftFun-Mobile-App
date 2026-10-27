import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'haptic_service.dart';

class ChapterCompletionDialog {
  const ChapterCompletionDialog._();

  static Future<void> show(
    BuildContext context, {
    required int chapter,
    required int score,
    required int total,
    bool allChaptersComplete = false,
  }) async {
    DraftFunHaptics.success();

    final percentage = total <= 0 ? 0 : ((score / total) * 100).round();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final screen = MediaQuery.sizeOf(dialogContext);
        final compact = screen.height < 500;

        void closeDialog() {
          Navigator.of(dialogContext).pop();
        }

        return SafeArea(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 28,
              vertical: compact ? 10 : 20,
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 320),
              tween: Tween<double>(begin: .90, end: 1),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0).toDouble(),
                  child: child,
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 560,
                  maxHeight: screen.height * 0.90,
                ),
                child: Material(
                  color: const Color(0xFFF8FBF7),
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 20 : 26,
                          compact ? 18 : 24,
                          compact ? 20 : 26,
                          compact ? 18 : 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: compact ? 29 : 36,
                              backgroundColor: const Color(0xFFB7F34A),
                              child: Icon(
                                Icons.emoji_events_rounded,
                                color: const Color(0xFF0B2B1A),
                                size: compact ? 34 : 42,
                              ),
                            ),
                            SizedBox(height: compact ? 8 : 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                allChaptersComplete
                                    ? 'DRAFTFUN COMPLETED!'
                                    : 'CHAPTER $chapter COMPLETED!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.vastShadow(
                                  color: const Color(0xFF0B2B1A),
                                  fontSize: compact ? 19 : 24,
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 5 : 8),
                            Text(
                              allChaptersComplete
                                  ? 'You completed all four chapters.'
                                  : 'Great work! Your next chapter is ready when available.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: compact ? 12 : 14,
                              ),
                            ),
                            SizedBox(height: compact ? 9 : 14),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 10 : 14,
                                vertical: compact ? 6 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB7F34A)
                                    .withValues(alpha: .18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFB7F34A),
                                ),
                              ),
                              child: Text(
                                allChaptersComplete
                                    ? 'ACHIEVEMENT UNLOCKED • DRAFTING MASTER'
                                    : 'ACHIEVEMENT UNLOCKED • CHAPTER $chapter MASTER',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF0B2B1A),
                                  fontSize: compact ? 10 : 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 7 : 10),
                            Text(
                              '$score / $total  •  $percentage%',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0B2B1A),
                                fontSize: compact ? 16 : 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: compact ? 12 : 18),
                            SizedBox(
                              width: double.infinity,
                              height: compact ? 52 : 58,
                              child: FilledButton(
                                onPressed: closeDialog,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFB7F34A),
                                  foregroundColor: const Color(0xFF0B2B1A),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  allChaptersComplete
                                      ? 'BACK TO CHAPTERS'
                                      : 'CONTINUE',
                                  style: GoogleFonts.vastShadow(
                                    fontSize: compact ? 14 : 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                   
                      Positioned(
                        top: 6,
                        right: 6,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            tooltip: 'Close',
                            onPressed: closeDialog,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF0B2B1A),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
