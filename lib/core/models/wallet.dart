class Transaction {
  final int id;
  final String userId;
  final String transactionType;
  final double amount;
  final DateTime transactionDate;

  Transaction({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      transactionType: json['transaction_type'] as String,
      amount: double.parse(json['amount']),
      transactionDate: DateTime.parse(json['transaction_date']),
    );
  }
}

class WalletModel {
  double totalAmount,availableToWithdraw;
  WalletModel({
   required this.totalAmount,
   required this.availableToWithdraw,
});

  factory WalletModel.fromJson(Map json){
    return WalletModel(
        totalAmount: double.parse(json["wallet_total"].toString()),
        availableToWithdraw:double.parse(json["withdraw"].toString())
    );
  }
}