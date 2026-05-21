import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../dashboard_colors.dart';

class DashboardProgressCard extends StatelessWidget {
  final String userUid;

  const DashboardProgressCard({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').where('uid', isEqualTo: userUid).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        final completed = docs.where((d) => (d.data() as Map<String, dynamic>)['stat'] == 'Hoàn thành').length;
        final double pct = total == 0 ? 0.0 : completed / total;
        final String pctStr = '${(pct * 100).toInt()}%';

        String sub;
        if (total == 0) {
          sub = 'Bạn có thể làm được nhiều điều.';
        } else if (pct >= 1.0) {
          sub = 'Bạn đã hoàn thành tất cả!';
        } else if (pct >= 0.5) {
          sub = 'Hãy tiếp tục nhé!';
        } else {
          sub = 'Bạn đang làm rất tốt.';
        }

        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: DashboardColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: DashboardColors.surfaceVariant.withValues(alpha: 0.20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 30, offset: const Offset(0, 10)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 10,
                        backgroundColor: DashboardColors.surfaceContainer,
                        valueColor: const AlwaysStoppedAnimation(DashboardColors.primary),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(pctStr, style: const TextStyle(color: DashboardColors.primary, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1.0)),
                        const SizedBox(height: 4),
                        const Text('TIẾN ĐỘ', style: TextStyle(color: DashboardColors.outline, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(total == 0 ? 'Chưa có công việc nào.' : '$completed trên $total công việc', style: const TextStyle(color: DashboardColors.onSurface, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text(sub, style: const TextStyle(color: DashboardColors.outline, fontSize: 15, fontWeight: FontWeight.w400)),
            ],
          ),
        );
      },
    );
  }
}
