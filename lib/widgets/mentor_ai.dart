library mentor_ai;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/voice_nudge_service.dart';

part 'mentor_ai/mentor_ai_date_range_picker.dart';
part 'mentor_ai/mentor_ai_report_dialog.dart';
part 'mentor_ai/mentor_ai_report_model.dart';
part 'mentor_ai/mentor_ai_report_helpers.dart';
part 'mentor_ai/mentor_ai_analysis_flow.dart';

class MentorAiButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final String subtitle;
  final IconData icon;

  const MentorAiButton({
    super.key,
    this.onPressed,
    this.title = 'Phân tích',
    this.subtitle = 'Xem gợi ý tối ưu hiệu suất học tập',
    this.icon = Icons.auto_awesome_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final surface = colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed ?? () => showAiAnalysisSheet(context),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: 0.95),
                primary.withValues(alpha: 0.72),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: surface.withValues(alpha: 0.20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.95),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}