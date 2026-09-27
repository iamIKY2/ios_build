import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<CategoryModel, double> breakdown;
  final double totalExpense;

  const CategoryPieChart({
    super.key,
    required this.breakdown,
    required this.totalExpense,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.breakdown.isEmpty || widget.totalExpense <= 0) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 48,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có dữ liệu chi tiêu trong kỳ này',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final entries = widget.breakdown.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 52,
                  sections: List.generate(entries.length, (i) {
                    final isTouched = i == touchedIndex;
                    final radius = isTouched ? 42.0 : 34.0;
                    final entry = entries[i];
                    final percent = (entry.value / widget.totalExpense) * 100;

                    return PieChartSectionData(
                      color: entry.key.color,
                      value: entry.value,
                      title: isTouched ? '${percent.toStringAsFixed(0)}%' : '',
                      radius: radius,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),

              // Center label inside Donut
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng chi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.formatCompactCurrency(widget.totalExpense),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Category breakdown list
        ...entries.map((entry) {
          final cat = entry.key;
          final amount = entry.value;
          final percent = (amount / widget.totalExpense) * 100;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cat.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                Text(
                  '${percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppFormatters.formatCurrency(amount),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class CashFlowBarWidget extends StatelessWidget {
  final double income;
  final double expense;

  const CashFlowBarWidget({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = income + expense;
    final incomeRatio = total > 0 ? (income / total) : 0.5;
    final expenseRatio = total > 0 ? (expense / total) : 0.5;
    final net = income - expense;

    return Container(
      padding: const EdgeInsets.all(18),
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
              Text(
                'Dòng tiền ròng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (net >= 0 ? AppColors.income : AppColors.expense).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  net >= 0 ? 'Thặng dư' : 'Thâm hụt',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: net >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${net >= 0 ? '+' : ''}${AppFormatters.formatCurrency(net)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: net >= 0 ? AppColors.income : AppColors.expense,
            ),
          ),
          const SizedBox(height: 16),

          // Stacked horizontal progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (incomeRatio * 100).toInt().clamp(1, 100),
                    child: Container(color: AppColors.income),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (expenseRatio * 100).toInt().clamp(1, 100),
                    child: Container(color: AppColors.expense),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Row legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.income,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Thu: ${AppFormatters.formatCompactCurrency(income)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.expense,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Chi: ${AppFormatters.formatCompactCurrency(expense)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
