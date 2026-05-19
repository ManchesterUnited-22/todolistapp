import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/avatar_service.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
class _C {
  static const background          = Color(0xFFF7F9FB);
  static const surface             = Color(0xFFFFFFFF);
  static const surfaceContainer    = Color(0xFFECEEF0);
  static const surfaceContainerHigh= Color(0xFFE6E8EA);
  static const surfaceVariant      = Color(0xFFE0E3E5);
  static const primary             = Color(0xFF6366F1);
  static const primaryFixed        = Color(0xFFE1E0FF);
  static const onSurface           = Color(0xFF191C1E);
  static const onSurfaceVariant    = Color(0xFF464554);
  static const outline             = Color(0xFF767586);
  static const outlineVariant      = Color(0xFFC7C4D7);
}

class EditProfileForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const EditProfileForm({super.key, required this.initialData});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  String? _avatarUrl;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
        text: widget.initialData['fullName'] as String? ?? '');
    _emailController = TextEditingController(
      text: widget.initialData['email'] as String? ?? '');
    _avatarUrl = widget.initialData['avatarUrl'] as String?;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final Map<String, dynamic> updatesRegister = {};
    final Map<String, dynamic> updatesUser = {};
    final full = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    if (full.isNotEmpty && full != (widget.initialData['fullName'] as String? ?? '')) updatesRegister['fullName'] = full;
    if (email.isNotEmpty && email != (widget.initialData['email'] as String? ?? '')) updatesRegister['email'] = email;
    if (_avatarUrl != null && _avatarUrl != (widget.initialData['avatarUrl'] as String?)) updatesUser['avatarUrl'] = _avatarUrl;

    if (updatesRegister.isNotEmpty) {
      updatesRegister['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      await FirebaseFirestore.instance.collection('register').doc(uid).set(updatesRegister, SetOptions(merge: true));
    }
    if (updatesUser.isNotEmpty) {
      updatesUser['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      await FirebaseFirestore.instance.collection('users').doc(uid).set(updatesUser, SetOptions(merge: true));
      // remove avatarUrl from register to keep single source
      try {
        await FirebaseFirestore.instance.collection('register').doc(uid).update({'avatarUrl': FieldValue.delete()});
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  

  // ── Avatar section (with camera button overlay) ───────────────────────────
  Widget _buildAvatar() {
    final avatarUrl = _avatarUrl ?? widget.initialData['avatarUrl'] as String?;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: _C.primary.withValues(alpha: 0.10), width: 4),
              color: _C.primaryFixed,
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person_rounded,
                            size: 48, color: _C.primary),
                  )
                : const Icon(Icons.person_rounded,
                    size: 48, color: _C.primary),
          ),

          // Camera button (bottom-right) - interactive
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final newUrl = await AvatarService.pickAndUploadAvatarToCloudinary(context);
                if (newUrl != null) setState(() => _avatarUrl = newUrl);
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _C.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4)
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.photo_camera_rounded,
                    color: Colors.white, size: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input field (matching HTML style) ────────────────────────────────────
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            color: _C.onSurface,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
                color: _C.outline.withValues(alpha: 0.60), fontSize: 15),
            filled: true,
            fillColor: _C.surfaceContainer,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: _C.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFEF4444), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 32,
                offset: const Offset(0, 8))
          ],
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header row ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chỉnh sửa hồ sơ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: _C.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close_rounded,
                            color: _C.outline, size: 22),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Avatar ──────────────────────────────────────────
                _buildAvatar(),

                const SizedBox(height: 24),

                // ── Fields ──────────────────────────────────────────
                _buildInput(
                  controller: _fullNameController,
                  label: 'Họ và tên',
                  placeholder: 'Nhập họ tên',
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return null; // optional
                    if (t.length < 2) return 'Họ tên quá ngắn';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _emailController,
                  label: 'Email',
                  placeholder: 'user@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return null; // optional
                    if (!t.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ── Action buttons ──────────────────────────────────
                Row(
                  children: [
                    // Hủy
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _C.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _C.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Lưu thay đổi
                    Expanded(
                      child: GestureDetector(
                        onTap: _saving ? null : _save,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _C.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _C.primary.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Lưu thay đổi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

 
