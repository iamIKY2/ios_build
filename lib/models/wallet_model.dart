import 'package:flutter/material.dart';

class WalletModel {
  final String id;
  final String name;
  final double balance;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final int colorValue;
  final String type; // 'cash', 'bank', 'credit', 'e_wallet', 'savings'
  final String? accountNumber;

  const WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    required this.colorValue,
    required this.type,
    this.accountNumber,
  });

  IconData get iconData => IconData(
        iconCodePoint,
        fontFamily: 'MaterialIcons',
      );

  Color get color => Color(colorValue);

  WalletModel copyWith({
    String? id,
    String? name,
    double? balance,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
    int? colorValue,
    String? type,
    String? accountNumber,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
      'colorValue': colorValue,
      'type': type,
      'accountNumber': accountNumber,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as String,
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      iconCodePoint: map['iconCodePoint'] as int,
      iconFontFamily: map['iconFontFamily'] as String?,
      iconFontPackage: map['iconFontPackage'] as String?,
      colorValue: map['colorValue'] as int,
      type: map['type'] as String,
      accountNumber: map['accountNumber'] as String?,
    );
  }

  static List<WalletModel> get defaultWallets => [
        WalletModel(
          id: 'wallet_vcb',
          name: 'Vietcombank Digi',
          balance: 38500000.0,
          iconCodePoint: Icons.account_balance.codePoint,
          colorValue: 0xFF059669, // Emerald
          type: 'bank',
          accountNumber: '•••• 6886',
        ),
        WalletModel(
          id: 'wallet_cash',
          name: 'Tiền mặt',
          balance: 3250000.0,
          iconCodePoint: Icons.account_balance_wallet.codePoint,
          colorValue: 0xFFF59E0B, // Amber
          type: 'cash',
          accountNumber: 'Trong ví',
        ),
        WalletModel(
          id: 'wallet_momo',
          name: 'Ví MoMo',
          balance: 1480000.0,
          iconCodePoint: Icons.phone_android.codePoint,
          colorValue: 0xFFD81B60, // Magenta
          type: 'e_wallet',
          accountNumber: '0988 •••• 99',
        ),
        WalletModel(
          id: 'wallet_savings',
          name: 'Quỹ tiết kiệm',
          balance: 120000000.0,
          iconCodePoint: Icons.savings_outlined.codePoint,
          colorValue: 0xFF6366F1, // Indigo
          type: 'savings',
          accountNumber: 'Kỳ hạn 12T',
        ),
      ];
}
