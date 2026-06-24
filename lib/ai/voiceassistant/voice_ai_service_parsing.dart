part of voice_ai_service;

String voiceAiVoicePromptForStep(VoiceTaskConversationState state) {
  switch (state.step) {
    case VoiceTaskStep.chooseWay:
      return 'Mình hỏi nhanh từng bước nhé. Bạn muốn tạo nhiệm vụ dài hạn hay Pomodoro (nhiệm vụ ngắn hạn)? Nhiệm vụ dài hạn là việc kéo dài nhiều bước. Pomodoro là nhiệm vụ ngắn theo phiên tập trung.';
    case VoiceTaskStep.confirmWay:
      return state.way == 'pomodoro'
          ? 'Mình nghe là bạn muốn tạo Pomodoro tức nhiệm vụ ngắn hạn. Bạn xác nhận chứ?'
          : 'Mình nghe là bạn muốn tạo nhiệm vụ dài hạn. Bạn xác nhận chứ?';
    case VoiceTaskStep.askTitle:
      return 'Tên nhiệm vụ là gì, nói ngắn gọn giúp mình nhé.';
    case VoiceTaskStep.askCategory:
      return 'Nhiệm vụ này thuộc nhóm nào: Công việc, Học tập, Cá nhân hay Sức khỏe?';
    case VoiceTaskStep.askDuration:
      return state.way == 'pomodoro'
          ? 'Pomodoro này bạn sẽ tập trung bao nhiêu phút?'
          : 'Nhiệm vụ này dự kiến kéo dài bao lâu (tính theo phút)?';
    case VoiceTaskStep.askPriority:
      return 'Mức độ ưu tiên của nhiệm vụ dài hạn là cao, vừa hay thấp?';
    case VoiceTaskStep.askDueAt:
      return 'Bạn muốn lên lịch nhiệm vụ vào ngày và giờ nào?';
    case VoiceTaskStep.confirm:
      return 'Mình sẽ lưu task này. Bạn nghe lại và xác nhận giúp mình nhé.';
    case VoiceTaskStep.done:
      return 'Đã xong.';
  }
}

VoiceTaskConversationReply voiceAiAdvanceVoiceTaskConversation(
  String userText,
  VoiceTaskConversationState state,
) {
  final text = userText.trim().toLowerCase();

  if (state.step == VoiceTaskStep.chooseWay) {
    final way = _parseWay(text);
    if (way == null) {
      return VoiceTaskConversationReply(
        state: state,
        prompt: 'Mình chưa rõ, bạn chọn task dài hạn hay Pomodoro nhé.',
        isComplete: false,
      );
    }
    return VoiceTaskConversationReply(
      state: state.copyWith(way: way, step: VoiceTaskStep.confirmWay),
      prompt: voiceAiVoicePromptForStep(
        state.copyWith(way: way, step: VoiceTaskStep.confirmWay),
      ),
      isComplete: false,
    );
  }

  if (state.step == VoiceTaskStep.confirmWay) {
    if (_isAffirmative(text)) {
      final next = state.copyWith(step: VoiceTaskStep.askTitle);
      return VoiceTaskConversationReply(
        state: next,
        prompt: voiceAiVoicePromptForStep(next),
        isComplete: false,
      );
    }
    return VoiceTaskConversationReply(
      state: VoiceTaskConversationState.initial(),
      prompt:
          'Được, mình bắt đầu lại. Bạn muốn nhiệm vụ dài hạn hay Promodoro?',
      isComplete: false,
    );
  }

  if (state.step == VoiceTaskStep.askTitle) {
    if (text.isEmpty) {
      return VoiceTaskConversationReply(
        state: state,
        prompt: 'Tên task chưa rõ, bạn nói lại giúp mình nhé.',
        isComplete: false,
      );
    }
    final next = state.copyWith(
      title: userText.trim(),
      step: VoiceTaskStep.askCategory,
    );
    return VoiceTaskConversationReply(
      state: next,
      prompt: voiceAiVoicePromptForStep(next),
      isComplete: false,
    );
  }

    if (state.step == VoiceTaskStep.askCategory) {
    final category = _parseCategory(text);
    if (category == null) {
      return VoiceTaskConversationReply(
        state: state,
        prompt:
            'Mình chưa nhận ra loại task. Bạn nói Công việc, Học tập, Cá nhân hoặc Sức khỏe nhé.',
        isComplete: false,
      );
    }
    final next = state.copyWith(
      category: category,
      step: VoiceTaskStep.askDuration,
    );
    return VoiceTaskConversationReply(
      state: next,
      prompt: voiceAiVoicePromptForStep(next),
      isComplete: false,
    );
  }

  if (state.step == VoiceTaskStep.askDuration) {
    final duration = _parseDurationMinutes(text);
    if (duration == null) {
      return VoiceTaskConversationReply(
        state: state,
        prompt: 'Mình cần một con số phút hợp lệ nhé.',
        isComplete: false,
      );
    }
    if (state.way == 'promodoro') {
      final next = state.copyWith(
        durationMinutes: duration,
        priority: 'Cao',
        step: VoiceTaskStep.askDueAt,
      );
      return VoiceTaskConversationReply(
        state: next,
        prompt: voiceAiVoicePromptForStep(next),
        isComplete: false,
      );
    }
    final next = state.copyWith(
      durationMinutes: duration,
      step: VoiceTaskStep.askPriority,
    );
    return VoiceTaskConversationReply(
      state: next,
      prompt: voiceAiVoicePromptForStep(next),
      isComplete: false,
    );
  }

  if (state.step == VoiceTaskStep.askPriority) {
    final priority = _parsePriority(text);
    if (priority == null) {
      return VoiceTaskConversationReply(
        state: state,
        prompt: 'Mức ưu tiên chưa rõ. Bạn nói cao, vừa hay thấp nhé.',
        isComplete: false,
      );
    }
    final next = state.copyWith(
      priority: priority,
      step: VoiceTaskStep.askDueAt,
    );
    return VoiceTaskConversationReply(
      state: next,
      prompt: voiceAiVoicePromptForStep(next),
      isComplete: false,
    );
  }

  if (state.step == VoiceTaskStep.askDueAt) {
    final dueAt = _parseDueAtVoice(text);
    final next = state.copyWith(dueAt: dueAt, step: VoiceTaskStep.confirm);
    final summary = _buildSummary(next);
    return VoiceTaskConversationReply(
      state: next,
      prompt: 'Xác nhận lại giúp mình: $summary',
      isComplete: false,
    );
  }

  if (state.step == VoiceTaskStep.confirm) {
    if (_isAffirmative(text)) {
      final draft = VoiceTaskDraft(
        way: state.way ?? 'long_term_task',
        title: state.title ?? 'Công việc mới',
        category: state.category ?? 'Công việc',
        durationMinutes: state.durationMinutes ?? 0,
        priority: state.priority ?? 'Vừa',
        dueAt: state.dueAt,
      );
      return VoiceTaskConversationReply(
        state: state.copyWith(step: VoiceTaskStep.done),
        prompt: 'Đã ghi nhận rồi.',
        isComplete: true,
        draft: draft,
      );
    }
    return VoiceTaskConversationReply(
      state: VoiceTaskConversationState.initial(),
      prompt: 'Được, mình làm lại từ đầu nhé.',
      isComplete: false,
    );
  }

  return VoiceTaskConversationReply(
    state: state,
    prompt: voiceAiVoicePromptForStep(state),
    isComplete: false,
  );
}
