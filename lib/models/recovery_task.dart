import 'wellbeing_score.dart';

enum InternPhase {
  preparation, // Chuẩn bị hành trang (Trước khi đi)
  adaptation,  // Hòa nhập tháng đầu (Tuần 1-4)
  sustain,     // Duy trì tiến độ (Tháng 2-3)
}

class RecoveryTask {
  final String id;
  final int day;
  final InternPhase phase;
  final PillarType pillar;
  final String title;
  final String description;
  final int durationMinutes;
  bool isCompleted;
  bool isLocked;

  RecoveryTask({
    required this.id,
    required this.day,
    required this.phase,
    required this.pillar,
    required this.title,
    required this.description,
    required this.durationMinutes,
    this.isCompleted = false,
    this.isLocked = false,
  });

  factory RecoveryTask.fromJson(Map<String, dynamic> json) {
    InternPhase parsePhase(String? val) {
      if (val == 'adaptation') return InternPhase.adaptation;
      if (val == 'sustain') return InternPhase.sustain;
      return InternPhase.preparation;
    }

    PillarType parsePillar(String? val) {
      if (val == 'sleep') return PillarType.sleep;
      if (val == 'physical') return PillarType.physical;
      if (val == 'mental') return PillarType.mental;
      if (val == 'social') return PillarType.social;
      if (val == 'career') return PillarType.career;
      return PillarType.mental;
    }

    return RecoveryTask(
      id: json['id']?.toString() ?? '',
      day: json['unlock_day'] ?? 0,
      phase: parsePhase(json['phase']),
      pillar: parsePillar(json['pillar']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 10,
      isCompleted: json['is_completed'] ?? false,
      isLocked: false,
    );
  }

  static List<RecoveryTask> get defaultTasks => [
        // PHASE 1: CHUẨN BỊ HÀNH TRANG (Ngày 0)
        RecoveryTask(id: 'p1_d0_ment', day: 0, phase: InternPhase.preparation, pillar: PillarType.mental, title: 'Đọc cẩm nang "Hành trang LG Display"', description: 'Tìm hiểu trước về văn hóa công ty, quy định 5S và các vật dụng cần thiết mang theo khi đi làm.', durationMinutes: 15, isLocked: false),
        RecoveryTask(id: 'p1_d0_phys', day: 0, phase: InternPhase.preparation, pillar: PillarType.physical, title: 'Chuẩn bị đồ dùng cá nhân y tế cơ bản', description: 'Chuẩn bị urgo, thuốc nhỏ mắt, thuốc tiêu hóa và các loại thuốc cơ bản để sẵn sàng cho môi trường mới.', durationMinutes: 10, isLocked: false),
        RecoveryTask(id: 'p1_d0_sleep', day: 0, phase: InternPhase.preparation, pillar: PillarType.sleep, title: 'Tập ngủ sớm trước 23:30', description: 'Điều chỉnh nhịp sinh học trước khi chính thức đi làm để không bị mệt mỏi trong những ngày đầu.', durationMinutes: 0, isLocked: false),
        RecoveryTask(id: 'p1_d0_soc', day: 0, phase: InternPhase.preparation, pillar: PillarType.social, title: 'Kết nối nhóm sinh viên cùng đợt', description: 'Tham gia group Zalo/Facebook của đợt thực tập để trao đổi thông tin và tìm bạn đồng hành.', durationMinutes: 10, isLocked: false),
        RecoveryTask(id: 'p1_d0_car', day: 0, phase: InternPhase.preparation, pillar: PillarType.career, title: 'Xác định mục tiêu thực tập', description: 'Viết ra 3 điều bạn muốn học được sau 3 tháng tới (kỹ năng cứng, mềm, mối quan hệ).', durationMinutes: 15, isLocked: false),

        // PHASE 2: HÒA NHẬP THÁNG ĐẦU (Ngày 1-30)
        RecoveryTask(id: 'p2_d1_ment', day: 1, phase: InternPhase.adaptation, pillar: PillarType.mental, title: 'Box Breathing: Vượt qua sự ngợp ngày đầu', description: 'Tập hít thở 4-4-4-4 trong 3 phút để giảm căng thẳng khi tiếp xúc với môi trường sản xuất quy mô lớn.', durationMinutes: 3, isLocked: false),
        RecoveryTask(id: 'p2_d2_sleep', day: 2, phase: InternPhase.adaptation, pillar: PillarType.sleep, title: 'Làm quen nhịp ca kíp: Không coffee chiều', description: 'Tránh uống cafe/bò húc sau 15h để đảm bảo có thể ngủ sâu vào ban đêm.', durationMinutes: 0, isLocked: false),
        RecoveryTask(id: 'p2_d3_phys', day: 3, phase: InternPhase.adaptation, pillar: PillarType.physical, title: 'Giãn cơ vai gáy sau ca làm', description: 'Thực hiện 3 động tác xoay cổ và căng vai gáy để tránh nhức mỏi.', durationMinutes: 5, isLocked: false),
        RecoveryTask(id: 'p2_d5_soc', day: 5, phase: InternPhase.adaptation, pillar: PillarType.social, title: 'Ăn trưa cùng một đồng nghiệp mới', description: 'Mở rộng giao tiếp, hỏi han về kinh nghiệm làm việc của các anh chị đi trước.', durationMinutes: 30, isLocked: false),
        RecoveryTask(id: 'p2_d7_car', day: 7, phase: InternPhase.adaptation, pillar: PillarType.career, title: 'Review tuần đầu: Những điều đã học', description: 'Ghi lại các quy trình cơ bản và thao tác máy móc bạn đã được hướng dẫn.', durationMinutes: 15, isLocked: false),
        RecoveryTask(id: 'p2_d10_ment', day: 10, phase: InternPhase.adaptation, pillar: PillarType.mental, title: 'Check-in cảm xúc: Nhận diện áp lực', description: 'Sử dụng nhật ký để viết ra những khó khăn đang gặp phải (đứng lâu, không quen việc...).', durationMinutes: 10, isLocked: false),
        RecoveryTask(id: 'p2_d12_phys', day: 12, phase: InternPhase.adaptation, pillar: PillarType.physical, title: 'Ngâm chân nước ấm', description: 'Giúp dãn mạch máu vùng bàn chân, xua tan cảm giác mỏi nhức do đứng làm việc lâu.', durationMinutes: 15, isLocked: false),
        RecoveryTask(id: 'p2_d15_sleep', day: 15, phase: InternPhase.adaptation, pillar: PillarType.sleep, title: 'Tắt màn hình 30p trước khi ngủ', description: 'Giảm tiếp xúc ánh sáng xanh để não bộ thư giãn.', durationMinutes: 30, isLocked: false),
        RecoveryTask(id: 'p2_d20_soc', day: 20, phase: InternPhase.adaptation, pillar: PillarType.social, title: 'Chia sẻ một khó khăn với quản lý/nhóm trưởng', description: 'Đừng ngại hỏi hoặc chia sẻ nếu bạn đang gặp bế tắc trong thao tác công việc.', durationMinutes: 15, isLocked: false),
        RecoveryTask(id: 'p2_d30_car', day: 30, phase: InternPhase.adaptation, pillar: PillarType.career, title: 'Đánh giá tháng 1: Bạn đã làm được gì?', description: 'Nhìn lại 1 tháng vừa qua, tự thưởng cho bản thân vì đã nỗ lực thích nghi.', durationMinutes: 15, isLocked: false),

        // PHASE 3: DUY TRÌ TIẾN ĐỘ (Ngày 31-90)
        RecoveryTask(id: 'p3_d35_phys', day: 35, phase: InternPhase.sustain, pillar: PillarType.physical, title: 'Tập thể dục nhẹ 15 phút mỗi ngày', description: 'Duy trì thói quen vận động để tăng sức bền cho những tháng tiếp theo.', durationMinutes: 15, isLocked: false),
        RecoveryTask(id: 'p3_d40_ment', day: 40, phase: InternPhase.sustain, pillar: PillarType.mental, title: 'Quản lý tài chính: Cắt giảm chi phí thừa', description: 'Đọc cẩm nang về quản lý chi tiêu và lập quỹ phòng hờ.', durationMinutes: 10, isLocked: false),
        RecoveryTask(id: 'p3_d45_sleep', day: 45, phase: InternPhase.sustain, pillar: PillarType.sleep, title: 'Xây dựng thói quen ngủ cố định (kể cả ngày nghỉ)', description: 'Giúp cơ thể không bị "jet lag" giữa các ca làm việc.', durationMinutes: 0, isLocked: false),
        RecoveryTask(id: 'p3_d50_car', day: 50, phase: InternPhase.sustain, pillar: PillarType.career, title: 'Tìm hiểu một quy trình làm việc nâng cao', description: 'Hỏi quản lý hoặc tài liệu công ty về nguyên lý hoạt động sâu hơn của máy móc bạn đang phụ trách.', durationMinutes: 20, isLocked: false),
        RecoveryTask(id: 'p3_d60_soc', day: 60, phase: InternPhase.sustain, pillar: PillarType.social, title: 'Tổ chức một buổi đi chơi nhỏ cùng phòng trọ/nhóm', description: 'Tái tạo năng lượng và thắt chặt tình cảm anh em.', durationMinutes: 120, isLocked: false),
        RecoveryTask(id: 'p3_d75_ment', day: 75, phase: InternPhase.sustain, pillar: PillarType.mental, title: 'Kiểm soát burn-out (kiệt sức)', description: 'Thực hành bài test mức độ căng thẳng để xem bạn có đang quá sức không.', durationMinutes: 5, isLocked: false),
        RecoveryTask(id: 'p3_d85_car', day: 85, phase: InternPhase.sustain, pillar: PillarType.career, title: 'Cập nhật CV với kinh nghiệm thực tập', description: 'Ghi lại những thành tích, số liệu và kỹ năng bạn đã tích lũy được trong 3 tháng qua.', durationMinutes: 30, isLocked: false),
        RecoveryTask(id: 'p3_d90_soc', day: 90, phase: InternPhase.sustain, pillar: PillarType.social, title: 'Nói lời cảm ơn và giữ liên lạc', description: 'Cảm ơn những người đã hướng dẫn bạn và xin thông tin liên lạc để duy trì network.', durationMinutes: 15, isLocked: false),
      ];
}
