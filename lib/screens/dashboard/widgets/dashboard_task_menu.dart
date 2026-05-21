import 'package:flutter/material.dart';
import '../dashboard_colors.dart';

void showDashboardTaskMenu({
  required BuildContext context,
  required VoidCallback onDelete,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: DashboardColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: DashboardColors.primary),
            title: const Text('Chỉnh sửa'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: DashboardColors.error),
            title: const Text('Xoá', style: TextStyle(color: DashboardColors.error)),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
