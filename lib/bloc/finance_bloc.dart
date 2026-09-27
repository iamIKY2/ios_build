import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/finance_repository.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository repository;

  FinanceBloc({required this.repository}) : super(const FinanceInitial()) {
    on<LoadFinanceData>(_onLoadData);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<AddWalletEvent>(_onAddWallet);
    on<UpdateWalletEvent>(_onUpdateWallet);
    on<DeleteWalletEvent>(_onDeleteWallet);
    on<UpdateMonthlyBudgetEvent>(_onUpdateBudget);
    on<ChangeFilterPeriodEvent>(_onChangePeriod);
    on<ChangeSearchQueryEvent>(_onChangeSearchQuery);
    on<ChangeFilterCategoryEvent>(_onChangeFilterCategory);
    on<ChangeFilterTypeEvent>(_onChangeFilterType);
    on<ResetDataEvent>(_onResetData);
  }

  void _onLoadData(LoadFinanceData event, Emitter<FinanceState> emit) {
    emit(const FinanceLoading());
    try {
      final transactions = repository.loadTransactions();
      final wallets = repository.loadWallets();
      final categories = repository.loadCategories();
      final budget = repository.loadMonthlyBudget();

      emit(FinanceLoaded(
        transactions: transactions,
        wallets: wallets,
        categories: categories,
        monthlyBudget: budget,
      ));
    } catch (e) {
      emit(FinanceError('Không thể tải dữ liệu tài chính: $e'));
    }
  }

  void _onAddTransaction(AddTransactionEvent event, Emitter<FinanceState> emit) async {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;

    final updatedTransactions = [event.transaction, ...currentState.transactions];

    // Cập nhật số dư ví tương ứng
    final updatedWallets = currentState.wallets.map((wallet) {
      if (wallet.id == event.transaction.walletId) {
        final newBalance = event.transaction.isExpense
            ? wallet.balance - event.transaction.amount
            : wallet.balance + event.transaction.amount;
        return wallet.copyWith(balance: newBalance);
      }
      return wallet;
    }).toList();

    emit(currentState.copyWith(
      transactions: updatedTransactions,
      wallets: updatedWallets,
    ));

    await repository.saveTransactions(updatedTransactions);
    await repository.saveWallets(updatedWallets);
  }

  void _onUpdateTransaction(UpdateTransactionEvent event, Emitter<FinanceState> emit) async {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;

    final oldTxIndex = currentState.transactions.indexWhere((t) => t.id == event.transaction.id);
    if (oldTxIndex == -1) return;
    final oldTx = currentState.transactions[oldTxIndex];

    final updatedTransactions = List.of(currentState.transactions);
    updatedTransactions[oldTxIndex] = event.transaction;

    // Hoàn tác số tiền cũ và cập nhật số tiền mới cho ví
    final updatedWallets = currentState.wallets.map((wallet) {
      var balance = wallet.balance;

      // Hoàn tác giao dịch cũ nếu cùng ví
      if (wallet.id == oldTx.walletId) {
        balance = oldTx.isExpense ? balance + oldTx.amount : balance - oldTx.amount;
      }

      // Áp dụng giao dịch mới nếu cùng ví
      if (wallet.id == event.transaction.walletId) {
        balance = event.transaction.isExpense
            ? balance - event.transaction.amount
            : balance + event.transaction.amount;
      }

      return wallet.copyWith(balance: balance);
    }).toList();

    emit(currentState.copyWith(
      transactions: updatedTransactions,
      wallets: updatedWallets,
    ));

    await repository.saveTransactions(updatedTransactions);
    await repository.saveWallets(updatedWallets);
  }

  void _onDeleteTransaction(DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;

    final txToDelete = currentState.transactions.firstWhere(
      (t) => t.id == event.transactionId,
      orElse: () => throw Exception('Transaction not found'),
    );

    final updatedTransactions = currentState.transactions
        .where((t) => t.id != event.transactionId)
        .toList();

    // Hoàn lại tiền vào ví
    final updatedWallets = currentState.wallets.map((wallet) {
      if (wallet.id == txToDelete.walletId) {
        final restoredBalance = txToDelete.isExpense
            ? wallet.balance + txToDelete.amount
            : wallet.balance - txToDelete.amount;
        return wallet.copyWith(balance: restoredBalance);
      }
      return wallet;
    }).toList();

    emit(currentState.copyWith(
      transactions: updatedTransactions,
      wallets: updatedWallets,
    ));

    await repository.saveTransactions(updatedTransactions);
    await repository.saveWallets(updatedWallets);
  }

  void _onAddWallet(AddWalletEvent event, Emitter<FinanceState> emit) async {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;

    final updatedWallets = [...currentState.wallets, event.wallet];

    emit(currentState.copyWith(wallets: updatedWallets));
    await repository.saveWallets(updatedWallets);
  }

  void _onUpdateWallet(UpdateWalletEvent event, Emitter<FinanceState> emit) async {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;

    final updatedWallets = currentState.wallets.map((w) {
      return w.id == event.wallet.id ? event.wallet : w;
    }).toList();

    emit(currentState.copyWith(wallets: updatedWallets));
    await repository.saveWallets(updatedWallets);
  }

  void _onDeleteWallet(DeleteWalletEvent event, Emitter<FinanceState> emit) async {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;

    final updatedWallets = currentState.wallets.where((w) => w.id != event.walletId).toList();

    emit(currentState.copyWith(wallets: updatedWallets));
    await repository.saveWallets(updatedWallets);
  }

  void _onUpdateBudget(UpdateMonthlyBudgetEvent event, Emitter<FinanceState> emit) async {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;

    emit(currentState.copyWith(monthlyBudget: event.budget));
    await repository.saveMonthlyBudget(event.budget);
  }

  void _onChangePeriod(ChangeFilterPeriodEvent event, Emitter<FinanceState> emit) {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;
    emit(currentState.copyWith(selectedPeriod: event.period));
  }

  void _onChangeSearchQuery(ChangeSearchQueryEvent event, Emitter<FinanceState> emit) {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;
    emit(currentState.copyWith(searchQuery: event.query));
  }

  void _onChangeFilterCategory(ChangeFilterCategoryEvent event, Emitter<FinanceState> emit) {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;
    emit(currentState.copyWith(selectedCategoryId: () => event.categoryId));
  }

  void _onChangeFilterType(ChangeFilterTypeEvent event, Emitter<FinanceState> emit) {
    if (state is! FinanceLoaded) return;
    final currentState = state as FinanceLoaded;
    emit(currentState.copyWith(selectedFilterType: event.filterType));
  }

  void _onResetData(ResetDataEvent event, Emitter<FinanceState> emit) async {
    await repository.resetToDefaults();
    add(const LoadFinanceData());
  }
}
