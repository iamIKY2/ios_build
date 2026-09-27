import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class FinanceRepository {
  static const String _keyTransactions = 'enigma_finance_transactions';
  static const String _keyWallets = 'enigma_finance_wallets';
  static const String _keyCategories = 'enigma_finance_categories';
  static const String _keyBudget = 'enigma_finance_monthly_budget';
  static const String _keyTheme = 'enigma_finance_theme_mode';

  final SharedPreferences _prefs;

  FinanceRepository(this._prefs);

  static Future<FinanceRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return FinanceRepository(prefs);
  }

  // === TRANSACTIONS ===
  List<TransactionModel> loadTransactions() {
    final raw = _prefs.getString(_keyTransactions);
    if (raw == null || raw.isEmpty) {
      final initial = TransactionModel.defaultTransactions;
      saveTransactions(initial);
      return initial;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => TransactionModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return TransactionModel.defaultTransactions;
    }
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final raw = jsonEncode(transactions.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyTransactions, raw);
  }

  // === WALLETS ===
  List<WalletModel> loadWallets() {
    final raw = _prefs.getString(_keyWallets);
    if (raw == null || raw.isEmpty) {
      final initial = WalletModel.defaultWallets;
      saveWallets(initial);
      return initial;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => WalletModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return WalletModel.defaultWallets;
    }
  }

  Future<void> saveWallets(List<WalletModel> wallets) async {
    final raw = jsonEncode(wallets.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyWallets, raw);
  }

  // === CATEGORIES ===
  List<CategoryModel> loadCategories() {
    final raw = _prefs.getString(_keyCategories);
    if (raw == null || raw.isEmpty) {
      final initial = CategoryModel.defaultCategories;
      saveCategories(initial);
      return initial;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => CategoryModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return CategoryModel.defaultCategories;
    }
  }

  Future<void> saveCategories(List<CategoryModel> categories) async {
    final raw = jsonEncode(categories.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyCategories, raw);
  }

  // === BUDGET ===
  double loadMonthlyBudget() {
    return _prefs.getDouble(_keyBudget) ?? 15000000.0; // 15 triệu mặc định
  }

  Future<void> saveMonthlyBudget(double budget) async {
    await _prefs.setDouble(_keyBudget, budget);
  }

  // === THEME MODE ===
  String loadThemeMode() {
    return _prefs.getString(_keyTheme) ?? 'dark'; // Dark theme default for luxury feel
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_keyTheme, mode);
  }

  // === RESET ALL TO DEFAULT ===
  Future<void> resetToDefaults() async {
    await _prefs.remove(_keyTransactions);
    await _prefs.remove(_keyWallets);
    await _prefs.remove(_keyCategories);
    await _prefs.remove(_keyBudget);
  }
}
