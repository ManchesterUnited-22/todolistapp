import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/stats_service.dart';
import '../../views/stats_viewmodel.dart';
import '../../views/task_viewmodel.dart';
import '../../widgets/floating_bottom_navbar.dart';
import '../../widgets/mentor_ai.dart';
import '../../widgets/sidebar.dart';
import '../../notifications/task_notification_bell.dart';
import 'charts_colors.dart';
import 'widgets/charts_distribution_section.dart';
import 'widgets/charts_focus_section.dart';
import 'widgets/charts_kpi_section.dart';
import 'widgets/charts_motivation_card.dart';
import 'widgets/charts_summary_banner.dart';
import 'widgets/charts_weekly_chart.dart';

class ChartsScreen extends StatefulWidget {
  final bool showBottomNav;

  const ChartsScreen({super.key, this.showBottomNav = true});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String _lastSyncedSignature = '';

  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ChartsColors.surface.withValues(alpha: 0.80),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: ChartsColors.outlineVariant.withValues(alpha: 0.30)),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: ChartsColors.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text(
        'Serene Focus',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ChartsColors.primary, letterSpacing: -0.5),
      ),
      actions: [
        TaskNotificationBellButton(userId: _currentUserUid, iconColor: ChartsColors.primary, badgeColor: ChartsColors.error),
      ],
    );
  }

  Widget _buildBody() {
    final uid = _currentUserUid;
    if (uid.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Vui lòng đăng nhập để xem thống kê.', style: TextStyle(color: ChartsColors.onSurfaceVariant, fontSize: 16)),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('tasks').where('uid', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Lỗi tải dữ liệu biểu đồ'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final tasks = snapshot.data!.docs.map((doc) => TaskViewModel.fromMap(doc.data())).toList();
        final stats = StatsViewModel.fromTasks(uid: uid, tasks: tasks);

        if (stats.syncSignature != _lastSyncedSignature) {
          _lastSyncedSignature = stats.syncSignature;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) StatsService.instance.saveUserStats(stats);
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ChartsSummaryBanner(stats: stats),
              const SizedBox(height: 20),
              const MentorAiButton(),
              const SizedBox(height: 32),
              ChartsKpiSection(stats: stats),
              const SizedBox(height: 32),
              ChartsWeeklyChart(tasks: tasks),
              const SizedBox(height: 32),
              ChartsDistributionSection(stats: stats),
              const SizedBox(height: 32),
              ChartsFocusSection(stats: stats),
              const SizedBox(height: 32),
              const ChartsMotivationCard(),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChartsColors.background,
      drawer: Drawer(
        width: 280,
        child: SafeArea(
          child: DashboardSidebar(
            currentPage: 'charts',
            userName: 'User Name',
            onDashboardTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/dashboard');
            },
            onCalendarTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/calendar');
            },
            onChartsTap: () => Navigator.of(context).pop(),
            onEditProfile: () => Navigator.of(context).pushNamed('/profile'),
            onLanguage: () => Navigator.of(context).pushNamed('/language'),
          ),
        ),
      ),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: widget.showBottomNav ? const FloatingBottomNavBar(currentIndex: 2, showFab: false) : null,
    );
  }
}
