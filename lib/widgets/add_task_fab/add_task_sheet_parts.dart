import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class AddTaskSheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const AddTaskSheetHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 28),
            color: Colors.grey[700],
          ),
          const Expanded(
            child: Text(
              'Thêm công việc mới',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4648D4),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              'https://lh3.googleusercontent.com/aida/ADBb0uhbD5XXHWIBotA981jxUvc9BV7E4JHroOM9na50zPAjMqddH5-96EdYrsxpELtu__YY7aGGTWFcdci0liNE2wXXplyTQbKPtrylOHZIVopc4RNexyxof9Q6opfaF6leJEBXl5zztxoS-xwTLPr9OI0hdNHrdXQuVCfdTkvEddYbtQ9Jq9eCHCfsGnEopd7BN-_0x_z4TRNxPETpOQLI5qtnEvXnhAYrEyVmoZ0Rqlk1cNEqkumNiG_RnFc',
            ),
          ),
        ],
      ),
    );
  }
}

class AddTaskSheetTip extends StatelessWidget {
  const AddTaskSheetTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida/ADBb0uhbD5XXHWIBotA981jxUvc9BV7E4JHroOM9na50zPAjMqddH5-96EdYrsxpELtu__YY7aGGTWFcdci0liNE2wXXplyTQbKPtrylOHZIVopc4RNexyxof9Q6opfaF6leJEBXl5zztxoS-xwTLPr9OI0hdNHrdXQuVCfdTkvEddYbtQ9Jq9eCHCfsGnEopd7BN-_0x_z4TRNxPETpOQLI5qtnEvXnhAYrEyVmoZ0Rqlk1cNEqkumNiG_RnFc',
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serene gợi ý:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4648D4),
                  ),
                ),
                Text(
                  'Hãy chia nhỏ công việc để hoàn thành dễ dàng hơn nhé!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddTaskSectionTitle extends StatelessWidget {
  final String text;

  const AddTaskSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

class AddTaskTimeDateSelector extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const AddTaskTimeDateSelector({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brand),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const AddTaskCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand : Colors.grey[100],
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskPriorityButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const AddTaskPriorityButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey[600]),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}