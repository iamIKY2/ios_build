import 'package:equatable/equatable.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import 'finance_event.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {
  const FinanceInitial();
}

class FinanceLoading extends FinanceState {
  const FinanceLoading();
}

class FinanceLoaded extends FinanceState {
  final List<TransactionModel> transactions;
  final List<WalletModel> wallets;
  final List<CategoryModel> categories;
  final double monthlyBudget;
  final FilterPeriod selectedPeriod;
  final String searchQuery;
  final String? selectedCategoryId;
  final TransactionFilterType selectedFilterType;

  const FinanceLoaded({
    required this.transactions,
    required this.wallets,
    required this.categories,
    required this.monthlyBudget,
    this.selectedPeriod = FilterPeriod.month,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.selectedFilterType = TransactionFilterType.all,
  });

  FinanceLoaded copyWith({
    List<TransactionModel>? transactions,
    List<WalletModel>? wallets,
    List<CategoryModel>? categories,
    double? monthlyBudget,
    FilterPeriod? selectedPeriod,
    String? searchQuery,
    String? Function()? selectedCategoryId,
    TransactionFilterType? selectedFilterType,
  }) {
    return FinanceLoaded(
      transactions: transactions ?? this.transactions,
      wallets: wallets ?? this.wallets,
      categories: categories ?? this.categories,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId != null ? selectedCategoryId() : this.selectedCategoryId,
      selectedFilterType: selectedFilterType ?? this.selectedFilterType,
    );
  }

  // === CALCULATED METRICS ===
  double get totalBalance {
    return wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  }

  // This calendar month metrics
  DateTime get _now => DateTime.now();

  List<TransactionModel> get thisMonthTransactions {
    return transactions.where((tx) {
      return tx.date.year == _now.year && tx.date.month == _now.month;
    }).toList();
  }

  double get thisMonthIncome {
    return thisMonthTransactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get thisMonthExpense {
    return thisMonthTransactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get thisMonthSavings => thisMonthIncome - thisMonthExpense;

  double get thisMonthSavingsRate {
    if (thisMonthIncome <= 0) return 0.0;
    final rate = (thisMonthSavings / thisMonthIncome) * 100;
    return rate.clamp(-100.0, 100.0);
  }

  double get budgetUsedPercent {
    if (monthlyBudget <= 0) return 0.0;
    return (thisMonthExpense / monthlyBudget * 100).clamp(0.0, 100.0);
  }

  bool get isBudgetExceeded => thisMonthExpense > monthlyBudget;

  // Filtered transactions based on period, search query, type, category
  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    var list = transactions.where((tx) {
      // Filter by period
      if (selectedPeriod == FilterPeriod.week) {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final dateWithoutTime = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final startWithoutTime = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        if (dateWithoutTime.isBefore(startWithoutTime)) return false;
      } else if (selectedPeriod == FilterPeriod.month) {
        if (tx.date.year != now.year || tx.date.month != now.month) return false;
      } else if (selectedPeriod == FilterPeriod.year) {
        if (tx.date.year != now.year) return false;
      }

      // Filter by type
      if (selectedFilterType == TransactionFilterType.expense && !tx.isExpense) {
        return false;
      }
      if (selectedFilterType == TransactionFilterType.income && tx.isExpense) {
        return false;
      }

      // Filter by category
      if (selectedCategoryId != null && tx.categoryId != selectedCategoryId) {
        return false;
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final titleMatch = tx.title.toLowerCase().contains(q);
        final noteMatch = tx.note?.toLowerCase().contains(q) ?? false;
        final cat = getCategoryById(tx.categoryId);
        final catMatch = cat?.name.toLowerCase().contains(q) ?? false;
        if (!titleMatch && !noteMatch && !catMatch) return false;
      }

      return true;
    }).toList();

    // Sort descending by date
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Filtered income & expense in active period
  double get periodIncome {
    return filteredTransactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get periodExpense {
    return filteredTransactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Category breakdown for expenses in active period
  Map<CategoryModel, double> get categoryExpenseBreakdown {
    final Map<String, double> map = {};
    for (final tx in filteredTransactions) {
      if (tx.isExpense) {
        map[tx.categoryId] = (map[tx.categoryId] ?? 0.0) + tx.amount;
      }
    }

    final result = <CategoryModel, double>{};
    for (final entry in map.entries) {
      final cat = getCategoryById(entry.key);
      if (cat != null) {
        result[cat] = entry.value;
      }
    }

    // Sort descending by amount
    final sortedKeys = result.keys.toList()
      ..sort((a, b) => result[b]!.compareTo(result[a]!));

    return {for (var k in sortedKeys) k: result[k]!};
  }

  List<TransactionModel> get recentTransactions {
    final list = List<TransactionModel>.from(transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(5).toList();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  WalletModel? getWalletById(String id) {
    try {
      return wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        transactions,
        wallets,
        categories,
        monthlyBudget,
        selectedPeriod,
        searchQuery,
        selectedCategoryId,
        selectedFilterType,
      ];
}

class FinanceError extends FinanceState {
  final String message;
  const FinanceError(this.message);

  @override
  List<Object?> get props => [message];
}
