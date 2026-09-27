class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final String categoryId;
  final String walletId;
  final DateTime date;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.categoryId,
    required this.walletId,
    required this.date,
    this.note,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isExpense,
    String? categoryId,
    String? walletId,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense,
      'categoryId': categoryId,
      'walletId': walletId,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      isExpense: map['isExpense'] as bool,
      categoryId: map['categoryId'] as String,
      walletId: map['walletId'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  static List<TransactionModel> get defaultTransactions {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'tx_1',
        title: 'Lương tháng này',
        amount: 28000000.0,
        isExpense: false,
        categoryId: 'cat_salary',
        walletId: 'wallet_vcb',
        date: DateTime(now.year, now.month, 5, 9, 30),
        note: 'Lương công ty chuyển khoản',
      ),
      TransactionModel(
        id: 'tx_2',
        title: 'Cà phê sáng & Ăn trưa',
        amount: 85000.0,
        isExpense: true,
        categoryId: 'cat_food',
        walletId: 'wallet_momo',
        date: DateTime(now.year, now.month, now.day, 12, 15),
        note: 'Cơm trưa văn phòng cùng đồng nghiệp',
      ),
      TransactionModel(
        id: 'tx_3',
        title: 'Đi siêu thị WinMart',
        amount: 645000.0,
        isExpense: true,
        categoryId: 'cat_shopping',
        walletId: 'wallet_vcb',
        date: DateTime(now.year, now.month, now.day - 1, 18, 45),
        note: 'Mua thực phẩm tuần',
      ),
      TransactionModel(
        id: 'tx_4',
        title: 'Đổ xăng xe máy',
        amount: 90000.0,
        isExpense: true,
        categoryId: 'cat_transport',
        walletId: 'wallet_cash',
        date: DateTime(now.year, now.month, now.day - 1, 8, 10),
        note: 'Cây xăng Petrolimex',
      ),
      TransactionModel(
        id: 'tx_5',
        title: 'Thưởng dự án hoàn thành',
        amount: 5000000.0,
        isExpense: false,
        categoryId: 'cat_bonus',
        walletId: 'wallet_vcb',
        date: DateTime(now.year, now.month, now.day - 2, 16, 20),
        note: 'Thưởng KPI quý',
      ),
      TransactionModel(
        id: 'tx_6',
        title: 'Tiền điện & Nước sinh hoạt',
        amount: 1120000.0,
        isExpense: true,
        categoryId: 'cat_bills',
        walletId: 'wallet_vcb',
        date: DateTime(now.year, now.month, now.day - 3, 10, 0),
        note: 'Hóa đơn EVN HCMC',
      ),
      TransactionModel(
        id: 'tx_7',
        title: 'Đăng ký phòng gym & Yoga',
        amount: 750000.0,
        isExpense: true,
        categoryId: 'cat_health',
        walletId: 'wallet_vcb',
        date: DateTime(now.year, now.month, now.day - 4, 19, 30),
        note: 'Gói tập tháng',
      ),
      TransactionModel(
        id: 'tx_8',
        title: 'Vé xem phim cuối tuần',
        amount: 240000.0,
        isExpense: true,
        categoryId: 'cat_entertainment',
        walletId: 'wallet_momo',
        date: DateTime(now.year, now.month, now.day - 5, 20, 0),
        note: 'CGV Cinema kèm bắp nước',
      ),
      TransactionModel(
        id: 'tx_9',
        title: 'Lãi tiết kiệm ngân hàng',
        amount: 620000.0,
        isExpense: false,
        categoryId: 'cat_investment',
        walletId: 'wallet_savings',
        date: DateTime(now.year, now.month, now.day - 6, 8, 0),
        note: 'Lãi suất gửi tiết kiệm định kỳ',
      ),
      TransactionModel(
        id: 'tx_10',
        title: 'Mua sách phát triển bản thân',
        amount: 320000.0,
        isExpense: true,
        categoryId: 'cat_education',
        walletId: 'wallet_cash',
        date: DateTime(now.year, now.month, now.day - 7, 14, 10),
        note: 'Tiki Now giao sách',
      ),
    ];
  }
}
