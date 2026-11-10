import 'package:enigma/core/utils/life_log_symptoms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calm and light levels offer only positive states', () {
    for (final level in [1, 2]) {
      final states = lifeLogSymptomsForStressLevel(level);
      expect(states, isNotEmpty);
      expect(states.every((s) => !s.isSymptom), isTrue);
    }
    expect(lifeLogSymptomsForStressLevel(1).map((s) => s.label),
        containsAll(['Cơ thể thoải mái', 'Đầu óc tỉnh táo', 'Ngủ ngon']));
  });

  test(
      'middle level mixes neutral states and mild symptoms; high levels use symptoms',
      () {
    final middle = lifeLogSymptomsForStressLevel(3);
    expect(middle.any((s) => !s.isSymptom), isTrue);
    expect(middle.any((s) => s.isSymptom), isTrue);
    for (final level in [4, 5]) {
      expect(lifeLogSymptomsForStressLevel(level).every((s) => s.isSymptom),
          isTrue);
    }
    for (var level = 1; level <= 5; level++) {
      final states = lifeLogSymptomsForStressLevel(level);
      expect(states.map((s) => s.label).toSet(), hasLength(states.length));
      expect(states.every((s) => s.icon.isNotEmpty), isTrue);
    }
  });

  test('positive choices are preserved in note without symptom penalties', () {
    final result = lifeLogBodyStatePayload(
        1, ['Cơ thể thoải mái', 'Ngủ ngon'], '  Hôm nay rất vui  ');
    expect(result.symptoms, isEmpty);
    expect(result.note,
        'Trạng thái thể chất: Cơ thể thoải mái, Ngủ ngon.\nHôm nay rất vui');
  });

  test('mixed choices separate positive states from symptoms', () {
    final result = lifeLogBodyStatePayload(
        3, ['Thể trạng bình thường', 'Mỏi mắt nhẹ'], '');
    expect(result.symptoms, ['Mỏi mắt nhẹ']);
    expect(result.note, 'Trạng thái thể chất: Thể trạng bình thường.');
  });

  test('save excludes stale hidden choices after changing levels', () {
    final result =
        lifeLogBodyStatePayload(1, ['Đau đầu', 'Cơ thể thoải mái'], '');
    expect(result.symptoms, isEmpty);
    expect(result.note, 'Trạng thái thể chất: Cơ thể thoải mái.');
    final stressed = lifeLogBodyStatePayload(4, ['Đau đầu', 'Ngủ ngon'], '');
    expect(stressed.symptoms, ['Đau đầu']);
    expect(stressed.note, isNull);
    expect(lifeLogBodyStatePayload(2, [], '   ').note, isNull);
  });

  test('lists remain stable and out-of-range levels are bounded', () {
    final initial = lifeLogSymptomsForStressLevel(2);
    lifeLogSymptomsForStressLevel(2).clear();
    expect(lifeLogSymptomsForStressLevel(2), initial);
    expect(lifeLogSymptomsForStressLevel(0), lifeLogSymptomsForStressLevel(1));
    expect(lifeLogSymptomsForStressLevel(6), lifeLogSymptomsForStressLevel(5));
  });
}
