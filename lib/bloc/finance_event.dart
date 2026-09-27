import 'package:equatable/equatable.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

enum FilterPeriod { all, week, month, year }
enum TransactionFilterType { all, expense, income }

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadFinanceData extends FinanceEvent {
  const LoadFinanceData();
}

class AddTransactionEvent extends FinanceEvent {
  final TransactionModel transaction;
  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends FinanceEvent {
  final TransactionModel transaction;
  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends FinanceEvent {
  final String transactionId;
  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class AddWalletEvent extends FinanceEvent {
  final WalletModel wallet;
  const AddWalletEvent(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class UpdateWalletEvent extends FinanceEvent {
  final WalletModel wallet;
  const UpdateWalletEvent(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class DeleteWalletEvent extends FinanceEvent {
  final String walletId;
  const DeleteWalletEvent(this.walletId);

  @override
  List<Object?> get props => [walletId];
}

class UpdateMonthlyBudgetEvent extends FinanceEvent {
  final double budget;
  const UpdateMonthlyBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class ChangeFilterPeriodEvent extends FinanceEvent {
  final FilterPeriod period;
  const ChangeFilterPeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}

class ChangeSearchQueryEvent extends FinanceEvent {
  final String query;
  const ChangeSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ChangeFilterCategoryEvent extends FinanceEvent {
  final String? categoryId;
  const ChangeFilterCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ChangeFilterTypeEvent extends FinanceEvent {
  final TransactionFilterType filterType;
  const ChangeFilterTypeEvent(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

class ResetDataEvent extends FinanceEvent {
  const ResetDataEvent();
}
