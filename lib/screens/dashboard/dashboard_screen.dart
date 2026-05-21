import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/floating_bottom_navbar.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/voicebutton/voice_button.dart';
import '../../widgets/voicebutton/voice_handler.dart';
import '../../views/task_viewmodel.dart';
import 'dashboard_colors.dart';
import 'widgets/dashboard_greeting_section.dart';
import 'widgets/dashboard_progress_card.dart';
import 'widgets/dashboard_task_list.dart';
import 'widgets/dashboard_top_bar.dart';

class MainDashboardScreen extends StatefulWidget {
  final bool showBottomNav;

  const MainDashboardScreen({super.key, this.showBottomNav = true});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  bool _showSidebar = false;
  String? _selectedCategory;

  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  void _toggleSidebar() => setState(() => _showSidebar = !_showSidebar);

  Future<void> _toggleTaskStatus(String docId, TaskViewModel task, bool checked) async {
    final stat = checked ? 'Hoàn thành' : (task.dueAt == null ? 'Đang làm' : (task.dueAt!.toDate().isBefore(DateTime.now()) ? 'Quá hạn' : 'Đang làm'));
    final updates = <String, dynamic>{'stat': stat};
    if (checked) {
      updates['completedAt'] = FieldValue.serverTimestamp();
    } else {
      updates['completedAt'] = FieldValue.delete();
    }
    await FirebaseFirestore.instance.collection('tasks').doc(docId).update(updates);
  }

  Future<void> _deleteTask(String docId) async => FirebaseFirestore.instance.collection('tasks').doc(docId).delete();

  String _taskSectionTitle() => _selectedCategory == null ? 'Danh sách việc làm' : 'Danh sách việc làm • $_selectedCategory';

  Widget _buildHomeContent() {
    return Column(
      children: [
        DashboardTopBar(onMenuTap: _toggleSidebar, userUid: _currentUserUid),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardGreetingSection(userUid: _currentUserUid),
                const SizedBox(height: 32),
                DashboardProgressCard(userUid: _currentUserUid),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _taskSectionTitle(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DashboardColors.onSurface, letterSpacing: -0.2),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_selectedCategory != null) setState(() => _selectedCategory = null);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          _selectedCategory == null ? 'Xem tất cả' : 'Bỏ lọc',
                          style: const TextStyle(fontSize: 14, color: DashboardColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DashboardTaskList(
                  userUid: _currentUserUid,
                  selectedCategory: _selectedCategory,
                  onToggleTask: _toggleTaskStatus,
                  onDeleteTask: _deleteTask,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildHomeContent(),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          opacity: _showSidebar ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !_showSidebar,
            child: GestureDetector(
              onTap: _toggleSidebar,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          left: _showSidebar ? 0 : -280,
          top: 0,
          bottom: 0,
          width: 280,
          child: DashboardSidebar(
            currentPage: 'dashboard',
            userName: 'User Name',
            selectedTag: _selectedCategory,
            onTagSelected: (category) {
              setState(() {
                _selectedCategory = category;
                _showSidebar = false;
              });
            },
            onDashboardTap: () {
              setState(() {
                _selectedCategory = null;
                _showSidebar = false;
              });
            },
            onCalendarTap: () {
              setState(() => _showSidebar = false);
              Navigator.of(context).pushNamed('/calendar');
            },
            onChartsTap: () {
              setState(() => _showSidebar = false);
              Navigator.of(context).pushNamed('/charts');
            },
            onEditProfile: () {},
            onLanguage: () => Navigator.of(context).pushNamed('/language'),
          ),
        ),
        if (widget.showBottomNav)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNavBar(currentIndex: 0, showFab: false),
          ),
        Positioned(
          bottom: 96,
          right: 24,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4648D4), Color(0xFF6063EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF4648D4).withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6)),
              ],
            ),
            child: VoiceTaskButton(
              onVoiceResult: (text) => VoiceHandler.process(text, context),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(child: _buildBody()),
    );
  }
}
