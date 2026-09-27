import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTransactionDetails(BuildContext context, dynamic tx, dynamic cat, dynamic wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: (cat?.color ?? AppColors.primary).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(cat?.iconData ?? Icons.receipt, color: cat?.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat?.name ?? 'Chung',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${tx.isExpense ? '-' : '+'}${AppFormatters.formatCurrency(tx.amount)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: tx.isExpense ? AppColors.expense : AppColors.income,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow('Thời gian', AppFormatters.formatDateTime(tx.date), isDark),
              _buildDetailRow('Ví thanh toán', wallet?.name ?? 'Mặc định', isDark),
              if (tx.note != null && tx.note!.isNotEmpty)
                _buildDetailRow('Ghi chú', tx.note!, isDark),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<FinanceBloc>().add(DeleteTransactionEvent(tx.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa giao dịch')),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: AppColors.expense),
                      label: const Text('Xóa', style: TextStyle(color: AppColors.expense)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.expense),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        AddTransactionScreen.show(context, initialTransaction: tx);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Chỉnh sửa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is! FinanceLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = state.filteredTransactions;
        final bloc = context.read<FinanceBloc>();

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Title & Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sổ giao dịch',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            bloc.add(ChangeSearchQueryEvent(val));
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm giao dịch, danh mục, ghi chú...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      bloc.add(const ChangeSearchQueryEvent(''));
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Tabs: All, Expense, Income
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildTypeFilterChip('Tất cả', TransactionFilterType.all, state.selectedFilterType, bloc, isDark),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Chi tiêu', TransactionFilterType.expense, state.selectedFilterType, bloc, isDark),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip('Thu nhập', TransactionFilterType.income, state.selectedFilterType, bloc, isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Period Filter: Tuần này, Tháng này, Năm nay, Tất cả
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPeriodChip('Tháng này', FilterPeriod.month, state.selectedPeriod, bloc, isDark),
                        const SizedBox(width: 6),
                        _buildPeriodChip('Tuần này', FilterPeriod.week, state.selectedPeriod, bloc, isDark),
                        const SizedBox(width: 6),
                        _buildPeriodChip('Năm nay', FilterPeriod.year, state.selectedPeriod, bloc, isDark),
                        const SizedBox(width: 6),
                        _buildPeriodChip('Tất cả thời gian', FilterPeriod.all, state.selectedPeriod, bloc, isDark),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Period Summary Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filtered.length} giao dịch',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '+${AppFormatters.formatCompactCurrency(state.periodIncome)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.income,
                              ),
                            ),
                            const Text(' / ', style: TextStyle(color: Colors.grey)),
                            Text(
                              '-${AppFormatters.formatCompactCurrency(state.periodExpense)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Transaction List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 54,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Không tìm thấy giao dịch nào phù hợp',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final tx = filtered[index];
                            final cat = state.getCategoryById(tx.categoryId);
                            final wallet = state.getWalletById(tx.walletId);

                            return Dismissible(
                              key: Key(tx.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.expense.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.white, size: 24),
                                    SizedBox(width: 8),
                                    Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xác nhận xóa'),
                                    content: Text('Bạn có chắc muốn xóa giao dịch "${tx.title}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Hủy'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) {
                                bloc.add(DeleteTransactionEvent(tx.id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã xóa "${tx.title}"')),
                                );
                              },
                              child: TransactionTile(
                                transaction: tx,
                                category: cat,
                                wallet: wallet,
                                onTap: () => _showTransactionDetails(context, tx, cat, wallet),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterChip(
    String label,
    TransactionFilterType type,
    TransactionFilterType active,
    FinanceBloc bloc,
    bool isDark,
  ) {
    final isSelected = active == type;
    return GestureDetector(
      onTap: () => bloc.add(ChangeFilterTypeEvent(type)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : AppColors.lightCardElevated),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(
    String label,
    FilterPeriod period,
    FilterPeriod active,
    FinanceBloc bloc,
    bool isDark,
  ) {
    final isSelected = active == period;
    return GestureDetector(
      onTap: () => bloc.add(ChangeFilterPeriodEvent(period)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkCardElevated : Colors.black12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
        ),
      ),
    );
  }
}
