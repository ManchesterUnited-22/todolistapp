import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';

class OnboardingStep2IllustrationCard extends StatelessWidget {
  const OnboardingStep2IllustrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4E3FF).withValues(alpha: 0.30),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE1E0FF).withValues(alpha: 0.20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Expanded(
                      child: _OnboardingStep2Image(),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        OnboardingStep2FloatingChip(
                          icon: Icons.priority_high_rounded,
                          label: 'High Priority',
                          color: Color(0xFF0060AC),
                          bgColor: Color(0xFF64A8FE),
                        ),
                        OnboardingStep2FloatingChip(
                          icon: Icons.done_all_rounded,
                          label: 'Done',
                          color: Color(0xFF006C49),
                          bgColor: Color(0xFF00885D),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep2Image extends StatelessWidget {
  const _OnboardingStep2Image();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBMh1C_Vxcp4ItFZwSfOI4LnO0GdrfJUOCXFdfOYtrQXDWpp9r7rSoKPvllVTpOto8T8ELZQr3E_DqTDdSIsbEiC55FV0xb7Hf9lxUnaS3LqHxjTqIOCxatUIsxSYRkB4A0T5nLKJiIS8Kua8Erg8YSQGDdNx1vZVS8UbnY2MvH5lwanbhpBq1wglJ9O7wpcuJH9Yg2foO2_iplzoOOn8SShlnyu9cAwYEQOS_N_eKZROR55zRm4qgOkkgXN7jtzJX5AFs5Gdp83LQ',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            color: AppColors.brand.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.task_alt_rounded,
            color: AppColors.brand,
            size: 64,
          ),
        ),
      ),
    );
  }
}

class OnboardingStep2FloatingChip extends StatelessWidget {
  const OnboardingStep2FloatingChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingStep2ProgressDot extends StatelessWidget {
  const OnboardingStep2ProgressDot({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.brand : const Color(0xFFC7C4D7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}