class Transaction {
  final int id;
  final String userId;
  final String transactionType;
  final double amount;
  final DateTime transactionDate;
  final String? transaction_status;

  Transaction({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.transaction_status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      transactionType: json['transaction_type'] as String,
      amount: double.parse(json['amount']),
      transactionDate: DateTime.parse(json['transaction_date']),
      transaction_status: json['transaction_status']  as String? ,
    );
  }
}

enum TransactionStatus{
  debit,
  credit
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

