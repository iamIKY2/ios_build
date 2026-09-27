import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final int colorValue;
  final bool isExpense;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    required this.colorValue,
    required this.isExpense,
  });

  IconData get iconData => IconData(
        iconCodePoint,
        fontFamily: 'MaterialIcons',
      );

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
      'colorValue': colorValue,
      'isExpense': isExpense,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['iconCodePoint'] as int,
      iconFontFamily: map['iconFontFamily'] as String?,
      iconFontPackage: map['iconFontPackage'] as String?,
      colorValue: map['colorValue'] as int,
      isExpense: map['isExpense'] as bool,
    );
  }

  static List<CategoryModel> get defaultCategories => [
        // Khoản chi (Expenses)
        CategoryModel(
          id: 'cat_food',
          name: 'Ăn uống',
          iconCodePoint: Icons.restaurant.codePoint,
          colorValue: 0xFFEF4444, // Red
          isExpense: true,
        ),
        CategoryModel(
          id: 'cat_shopping',
          name: 'Mua sắm',
          iconCodePoint: Icons.shopping_bag_outlined.codePoint,
          colorValue: 0xFFF59E0B, // Amber
          isExpense: true,
        ),
        CategoryModel(
          id: 'cat_transport',
          name: 'Di chuyển',
          iconCodePoint: Icons.directions_car_outlined.codePoint,
          colorValue: 0xFF3B82F6, // Blue
          isExpense: true,
        ),
        CategoryModel(
          id: 'cat_bills',
          name: 'Hóa đơn & Tiện ích',
          iconCodePoint: Icons.receipt_long_outlined.codePoint,
          colorValue: 0xFF8B5CF6, // Purple
          isExpense: true,
        ),
        CategoryModel(
          id: 'cat_entertainment',
          name: 'Giải trí',
          iconCodePoint: Icons.sports_esports_outlined.codePoint,
          colorValue: 0xFFEC4899, // Pink
          isExpense: true,
        ),
        CategoryModel(
          id: 'cat_health',
          name: 'Sức khỏe',
          iconCodePoint: Icons.favorite_border.codePoint,
          colorValue: 0xFF10B981, // Emerald
          isExpense: true,
        ),
        CategoryModel(
          id: 'cat_education',
          name: 'Giáo dục',
          iconCodePoint: Icons.school_outlined.codePoint,
          colorValue: 0xFF06B6D4, // Cyan
          isExpense: true,
        ),
        CategoryModel(
          id: 'cat_travel',
          name: 'Du lịch',
          iconCodePoint: Icons.flight_takeoff_outlined.codePoint,
          colorValue: 0xFFF97316, // Orange
          isExpense: true,
        ),

        // Khoản thu (Incomes)
        CategoryModel(
          id: 'cat_salary',
          name: 'Tiền lương',
          iconCodePoint: Icons.payments_outlined.codePoint,
          colorValue: 0xFF10B981, // Emerald
          isExpense: false,
        ),
        CategoryModel(
          id: 'cat_investment',
          name: 'Đầu tư & Tiết kiệm',
          iconCodePoint: Icons.trending_up.codePoint,
          colorValue: 0xFF059669, // Green
          isExpense: false,
        ),
        CategoryModel(
          id: 'cat_business',
          name: 'Kinh doanh',
          iconCodePoint: Icons.storefront_outlined.codePoint,
          colorValue: 0xFF6366F1, // Indigo
          isExpense: false,
        ),
        CategoryModel(
          id: 'cat_bonus',
          name: 'Thưởng & Hoa hồng',
          iconCodePoint: Icons.card_giftcard_outlined.codePoint,
          colorValue: 0xFFEAB308, // Yellow
          isExpense: false,
        ),
        CategoryModel(
          id: 'cat_other_income',
          name: 'Khoản thu khác',
          iconCodePoint: Icons.account_balance_wallet_outlined.codePoint,
          colorValue: 0xFF14B8A6, // Teal
          isExpense: false,
        ),
      ];
}
