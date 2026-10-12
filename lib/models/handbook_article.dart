class HandbookArticle {
  final String id;
  final String title;
  final String category;
  final String content;
  final String author;
  final DateTime publishedAt;
  final int helpfulCount;

  HandbookArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.author,
    required this.publishedAt,
    this.helpfulCount = 0,
  });

  static List<HandbookArticle> get mockArticles => [
    HandbookArticle(
      id: '1',
      title: 'Mẹo ăn uống tiết kiệm quanh KCN Tràng Duệ',
      category: 'Ăn uống',
      content: 'Bài viết chia sẻ danh sách các quán cơm bình dân, chợ tạm quanh KCN Tràng Duệ đảm bảo vệ sinh và giá cả hợp lý cho sinh viên thực tập.\n\n1. Quán Cơm Cô Hoa (Cổng 2)\n2. Chợ chiều Tân Tiến...',
      author: 'Cựu SV K60 - Bách Khoa',
      publishedAt: DateTime.now().subtract(const Duration(days: 30)),
      helpfulCount: 145,
    ),
    HandbookArticle(
      id: '2',
      title: 'Xử lý khi bị đau mỏi vai gáy do đứng chuyền',
      category: 'Sức khỏe',
      content: 'Kinh nghiệm thực tế từ các cựu sinh viên khi làm việc tại line sản xuất. Cách giãn cơ 5 phút giữa ca và các loại cao dán hiệu quả.',
      author: 'Cựu SV Y tế Công cộng',
      publishedAt: DateTime.now().subtract(const Duration(days: 15)),
      helpfulCount: 210,
    ),
    HandbookArticle(
      id: '3',
      title: 'Quyền lợi OT và Phụ cấp ca đêm',
      category: 'Quyền lợi',
      content: 'Giải thích chi tiết cách tính lương OT, phụ cấp làm đêm, và trợ cấp đi lại theo đúng quy định của công ty dành cho TTS.',
      author: 'Admin Enigma',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      helpfulCount: 320,
    ),
  ];
}
