import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? initialTransaction;

  const AddTransactionScreen({super.key, this.initialTransaction});

  static Future<void> show(BuildContext context, {TransactionModel? initialTransaction}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<FinanceBloc>(context),
        child: AddTransactionScreen(initialTransaction: initialTransaction),
      ),
    );
  }

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late bool _isExpense;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    _isExpense = tx?.isExpense ?? true;
    _titleController = TextEditingController(text: tx?.title ?? '');
    _amountController = TextEditingController(
      text: tx != null ? tx.amount.toInt().toString() : '',
    );
    _noteController = TextEditingController(text: tx?.note ?? '');
    _selectedCategoryId = tx?.categoryId;
    _selectedWalletId = tx?.walletId;
    _selectedDate = tx?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addAmount(int addition) {
    final current = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    _amountController.text = (current + addition).toString();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _isExpense ? AppColors.expense : AppColors.income,
              surface: AppColors.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (!mounted) return;
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time?.hour ?? _selectedDate.hour,
          time?.minute ?? _selectedDate.minute,
        );
      });
    }
  }

  void _submit() {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ!')),
      );
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên giao dịch!')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một danh mục!')),
      );
      return;
    }

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ví thanh toán!')),
      );
      return;
    }

    final bloc = context.read<FinanceBloc>();
    if (widget.initialTransaction != null) {
      final updated = widget.initialTransaction!.copyWith(
        title: title,
        amount: amount,
        isExpense: _isExpense,
        categoryId: _selectedCategoryId,
        walletId: _selectedWalletId,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      bloc.add(UpdateTransactionEvent(updated));
    } else {
      final newTx = TransactionModel(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        isExpense: _isExpense,
        categoryId: _selectedCategoryId!,
        walletId: _selectedWalletId!,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      bloc.add(AddTransactionEvent(newTx));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is! FinanceLoaded) {
          return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
        }
        final loadedState = state;

        // Set default wallet if not set
        if (_selectedWalletId == null && loadedState.wallets.isNotEmpty) {
          _selectedWalletId = loadedState.wallets.first.id;
        }

        // Filter categories according to expense / income
        final categories = loadedState.categories.where((c) => c.isExpense == _isExpense).toList();
        if (_selectedCategoryId == null && categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }

        final activeColor = _isExpense ? AppColors.expense : AppColors.income;

        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 25, offset: Offset(0, -5)),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header with Title and Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.initialTransaction != null ? 'Sửa giao dịch' : 'Thêm giao dịch mới',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Segmented Switch: Chi tiêu (Expense) vs Thu nhập (Income)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpense = true;
                                final expenseCats = loadedState.categories.where((c) => c.isExpense).toList();
                                _selectedCategoryId = expenseCats.isNotEmpty ? expenseCats.first.id : null;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isExpense ? AppColors.expense : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Chi tiêu',
                                style: TextStyle(
                                  color: _isExpense
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpense = false;
                                final incomeCats = loadedState.categories.where((c) => !c.isExpense).toList();
                                _selectedCategoryId = incomeCats.isNotEmpty ? incomeCats.first.id : null;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isExpense ? AppColors.income : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Thu nhập',
                                style: TextStyle(
                                  color: !_isExpense
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Amount input display
                  Text(
                    'Số tiền (VNĐ)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: activeColor.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: activeColor,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        suffixText: '₫',
                        suffixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Quick amount add chips
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickAddChip('+50K', 50000),
                        _buildQuickAddChip('+100K', 100000),
                        _buildQuickAddChip('+200K', 200000),
                        _buildQuickAddChip('+500K', 500000),
                        _buildQuickAddChip('+1Tr', 1000000),
                        _buildQuickAddChip('+5Tr', 5000000),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title / Description
                  Text(
                    'Tên giao dịch',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: _isExpense ? 'Vd: Ăn tối nhà hàng' : 'Vd: Lương tháng',
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.edit_note_outlined),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Picker
                  Text(
                    'Danh mục',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = _selectedCategoryId == cat.id;
                      return ChoiceChip(
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedCategoryId = cat.id);
                        },
                        avatar: Icon(
                          cat.iconData,
                          size: 16,
                          color: isSelected ? Colors.white : cat.color,
                        ),
                        label: Text(cat.name),
                        selectedColor: cat.color,
                        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? cat.color : Colors.transparent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Wallet selector & Date row
                  Row(
                    children: [
                      // Wallet dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ví thanh toán',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedWalletId,
                                  isExpanded: true,
                                  items: loadedState.wallets.map((w) {
                                    return DropdownMenuItem(
                                      value: w.id,
                                      child: Row(
                                        children: [
                                          Icon(w.iconData, size: 18, color: w.color),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              w.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() => _selectedWalletId = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Date Picker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thời gian',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        AppFormatters.formatDate(_selectedDate),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Note text field
                  Text(
                    'Ghi chú bổ sung (tùy chọn)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Nhập ghi chú chi tiết...',
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.lightCardElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: Text(
                        widget.initialTransaction != null ? 'Lưu thay đổi' : 'Ghi nhận giao dịch',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickAddChip(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        label: Text(label),
        onPressed: () => _addAmount(amount),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
