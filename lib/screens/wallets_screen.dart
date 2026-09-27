import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../models/wallet_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import '../widgets/wallet_card.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final accountController = TextEditingController();
    String selectedType = 'bank';
    int selectedColor = 0xFF6366F1;

    final availableColors = [
      0xFF059669, // Emerald
      0xFF6366F1, // Indigo
      0xFFD81B60, // Magenta
      0xFFF59E0B, // Amber
      0xFF0284C7, // Sky Blue
      0xFF7C3AED, // Violet
      0xFFDC2626, // Red
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm ví / tài khoản mới', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên ví / Ngân hàng',
                        hintText: 'Vd: MB Bank, Tiền mặt...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số dư ban đầu',
                        suffixText: '₫',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: accountController,
                      decoration: const InputDecoration(
                        labelText: 'Số tài khoản / Thẻ (tùy chọn)',
                        hintText: 'Vd: •••• 9988',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Loại tài khoản', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'bank', child: Text('Tài khoản ngân hàng')),
                        DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                        DropdownMenuItem(value: 'e_wallet', child: Text('Ví điện tử (MoMo, ZaloPay)')),
                        DropdownMenuItem(value: 'credit', child: Text('Thẻ tín dụng')),
                        DropdownMenuItem(value: 'savings', child: Text('Sổ tiết kiệm')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Màu sắc thẻ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: availableColors.map((c) {
                        final isSel = selectedColor == c;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = c),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final balance = double.tryParse(balanceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                    if (name.isEmpty) return;

                    IconData icon = Icons.account_balance;
                    if (selectedType == 'cash') icon = Icons.account_balance_wallet;
                    if (selectedType == 'e_wallet') icon = Icons.phone_android;
                    if (selectedType == 'credit') icon = Icons.credit_card;
                    if (selectedType == 'savings') icon = Icons.savings_outlined;

                    final newWallet = WalletModel(
                      id: const Uuid().v4(),
                      name: name,
                      balance: balance,
                      iconCodePoint: icon.codePoint,
                      colorValue: selectedColor,
                      type: selectedType,
                      accountNumber: accountController.text.trim().isEmpty ? null : accountController.text.trim(),
                    );

                    context.read<FinanceBloc>().add(AddWalletEvent(newWallet));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Thêm ví', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBudgetDialog(BuildContext context, double currentBudget) {
    final controller = TextEditingController(text: currentBudget.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cài đặt hạn mức ngân sách tháng'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Hạn mức chi tiêu tháng (VNĐ)',
            suffixText: '₫',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final newBudget = double.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'), ''));
              if (newBudget != null && newBudget > 0) {
                context.read<FinanceBloc>().add(UpdateMonthlyBudgetEvent(newBudget));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
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

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top Title & Add Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ví & Ngân sách',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddWalletDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm ví'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Monthly Budget Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hạn mức ngân sách',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kiểm soát chi tiêu tháng này',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                onPressed: () => _showEditBudgetDialog(context, state.monthlyBudget),
                                tooltip: 'Chỉnh sửa ngân sách',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${state.budgetUsedPercent.toStringAsFixed(1)}% đã sử dụng',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: state.isBudgetExceeded ? AppColors.expense : AppColors.primary,
                                ),
                              ),
                              Text(
                                'Còn lại: ${AppFormatters.formatCurrency((state.monthlyBudget - state.thisMonthExpense).clamp(0, double.infinity))}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (state.budgetUsedPercent / 100).clamp(0.0, 1.0),
                              minHeight: 10,
                              backgroundColor: isDark ? Colors.white10 : Colors.black12,
                              color: state.isBudgetExceeded ? AppColors.expense : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Wallets List Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Danh sách ví (${state.wallets.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),

                // Wallets Card List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final wallet = state.wallets[index];
                        return WalletCard(
                          wallet: wallet,
                        );
                      },
                      childCount: state.wallets.length,
                    ),
                  ),
                ),

                // Data reset demo button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Khôi phục dữ liệu mẫu?'),
                              content: const Text('Hành động này sẽ đặt lại tất cả các giao dịch và ví về trạng thái ban đầu.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                                  onPressed: () {
                                    context.read<FinanceBloc>().add(const ResetDataEvent());
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Khôi phục', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                        label: const Text(
                          'Khôi phục dữ liệu demo mẫu',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }
}
