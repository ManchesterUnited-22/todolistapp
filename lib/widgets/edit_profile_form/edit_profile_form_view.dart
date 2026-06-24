part of edit_profile_form;

Widget buildEditProfileDialog(_EditProfileFormState state, BuildContext context) {
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
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: state._formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      child: const Icon(
                        Icons.close_rounded,
                        color: _C.outline,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              state._buildAvatar(),
              const SizedBox(height: 24),
              state._buildInput(
                controller: state._fullNameController,
                label: 'Họ và tên',
                placeholder: 'Nhập họ tên',
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return null;
                  if (t.length < 2) return 'Họ tên quá ngắn';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              state._buildInput(
                controller: state._emailController,
                label: 'Email',
                placeholder: 'user@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return null;
                  if (!t.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
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
                  Expanded(
                    child: GestureDetector(
                      onTap: state._saving ? null : state._save,
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
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: state._saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
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
    ),
  );
}