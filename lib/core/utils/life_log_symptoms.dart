class LifeLogSymptom {
  final String icon;
  final String label;
  final bool isSymptom;

  const LifeLogSymptom(this.icon, this.label, {this.isSymptom = true});
}

// Self-report choices, not a diagnosis inferred from the stress level.
const _statesByStressLevel = <List<LifeLogSymptom>>[
  [
    LifeLogSymptom('😌', 'Cơ thể thoải mái', isSymptom: false),
    LifeLogSymptom('🧠', 'Đầu óc tỉnh táo', isSymptom: false),
    LifeLogSymptom('⚡', 'Tràn đầy năng lượng', isSymptom: false),
    LifeLogSymptom('🌿', 'Cơ bắp thư giãn', isSymptom: false),
    LifeLogSymptom('👁️', 'Đôi mắt dễ chịu', isSymptom: false),
    LifeLogSymptom('💤', 'Ngủ ngon', isSymptom: false),
  ],
  [
    LifeLogSymptom('🙂', 'Cơ thể nhẹ nhàng', isSymptom: false),
    LifeLogSymptom('🔋', 'Đủ năng lượng', isSymptom: false),
    LifeLogSymptom('🎯', 'Tập trung tốt', isSymptom: false),
    LifeLogSymptom('🌱', 'Thể trạng ổn định', isSymptom: false),
    LifeLogSymptom('🦴', 'Vai gáy dễ chịu', isSymptom: false),
    LifeLogSymptom('🛌', 'Nghỉ ngơi tốt', isSymptom: false),
  ],
  [
    LifeLogSymptom('😐', 'Thể trạng bình thường', isSymptom: false),
    LifeLogSymptom('🔋', 'Năng lượng vừa đủ', isSymptom: false),
    LifeLogSymptom('🥱', 'Hơi mệt'),
    LifeLogSymptom('👁️', 'Mỏi mắt nhẹ'),
    LifeLogSymptom('🦴', 'Căng vai gáy nhẹ'),
    LifeLogSymptom('💤', 'Hơi buồn ngủ'),
  ],
  [
    LifeLogSymptom('😵', 'Đau đầu'),
    LifeLogSymptom('🦴', 'Đau vai gáy'),
    LifeLogSymptom('🔩', 'Đau lưng'),
    LifeLogSymptom('👁️', 'Mỏi mắt'),
    LifeLogSymptom('😓', 'Mệt mỏi'),
    LifeLogSymptom('🌙', 'Khó ngủ'),
  ],
  [
    LifeLogSymptom('😵', 'Đau đầu nhiều'),
    LifeLogSymptom('🌡️', 'Chóng mặt'),
    LifeLogSymptom('🤢', 'Buồn nôn'),
    LifeLogSymptom('🪫', 'Kiệt sức'),
    LifeLogSymptom('🦴', 'Căng cứng cơ'),
    LifeLogSymptom('🌙', 'Mất ngủ'),
    LifeLogSymptom('💤', 'Ngủ gật'),
  ],
];

/// Choices progress from positive to uncomfortable across stress levels 1–5.
List<LifeLogSymptom> lifeLogSymptomsForStressLevel(int stressLevel) =>
    List.of(_statesByStressLevel[stressLevel.clamp(1, 5) - 1]);

/// Positive states are saved in the note, outside symptom scoring/risk screening.
({List<String> symptoms, String? note}) lifeLogBodyStatePayload(
  int stressLevel,
  Iterable<String> selected,
  String note,
) {
  final choices = lifeLogSymptomsForStressLevel(stressLevel)
      .where((state) => selected.contains(state.label));
  final symptoms = [
    for (final state in choices)
      if (state.isSymptom) state.label
  ];
  final positive = [
    for (final state in choices)
      if (!state.isSymptom) state.label
  ];
  final parts = [
    if (positive.isNotEmpty) 'Trạng thái thể chất: ${positive.join(', ')}.',
    if (note.trim().isNotEmpty) note.trim(),
  ];
  return (symptoms: symptoms, note: parts.isEmpty ? null : parts.join('\n'));
}
