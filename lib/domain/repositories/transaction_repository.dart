import '../models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions({String? type});

  Future<TransactionModel> getTransactionById(String id);

  Future<void> createTransaction(TransactionModel transaction);

  Future<void> updateTransaction(TransactionModel transaction);

  Future<void> deleteTransaction(String id);

  Future<Map<String, double>> getMonthlyStats(int year, int month);

  Future<List<Map<String, dynamic>>> getLast6MonthsSummary();
}
