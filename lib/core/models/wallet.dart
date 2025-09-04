class Transaction {
  final int id;
  final String userId;
  final String transactionType;
  final String transactionStatus;
  final double amount;
  final DateTime transactionDate;
  final bool isBankExist;


  Transaction({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.transactionStatus,
    required this.amount,
    required this.transactionDate,
    required this.isBankExist,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      transactionType: json['transaction_type'] as String,
      transactionStatus: json['transaction_status'] as String,
      amount: double.parse(json['amount']),
      transactionDate: DateTime.parse(json['transaction_date']),
      isBankExist: json.containsKey('vendor_bank_details') &&
          json['vendor_bank_details'] != null,
    );
  }
}
class WalletModel {
  final double totalAmount;
  final double availableToWithdraw;
  final bool isBankExist;

  WalletModel({
    required this.totalAmount,
    required this.availableToWithdraw,
    required this.isBankExist,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      totalAmount: double.parse(json["wallet_total"].toString()),
      availableToWithdraw: double.parse(json["withdraw"].toString()),
      isBankExist: json.containsKey("vendor_bank_details") && json["vendor_bank_details"] != null,
    );
  }
}
