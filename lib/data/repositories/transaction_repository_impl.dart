import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseClient _client;
  static const _table = 'transactions';

  TransactionRepositoryImpl(this._client);

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Pengguna tidak terautentikasi');
    return user.id;
  }

  @override
  Future<List<TransactionModel>> getTransactions({String? type}) async {
    var query = _client
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .order('date', ascending: false);

    final response = type != null
        ? await _client
              .from(_table)
              .select()
              .eq('user_id', _userId)
              .eq('type', type)
              .order('date', ascending: false)
        : await query;

    return (response as List)
        .map((e) => TransactionModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .single();
    return TransactionModel.fromMap(response);
  }

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    await _client.from(_table).insert(transaction.toInsertMap());
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _client
        .from(_table)
        .update({
          'title': transaction.title,
          'amount': transaction.amount,
          'type': transaction.type,
          'category': transaction.category,
          'date': transaction.date.toIso8601String(),
        })
        .eq('id', transaction.id)
        .eq('user_id', _userId);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _client
        .from(_table)
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  @override
  Future<Map<String, double>> getMonthlyStats(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .gte('date', startDate.toIso8601String())
        .lt('date', endDate.toIso8601String());

    double income = 0;
    double expense = 0;

    for (final item in response as List) {
      final tx = TransactionModel.fromMap(item as Map<String, dynamic>);
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    return {'income': income, 'expense': expense};
  }

  @override
  Future<List<Map<String, dynamic>>> getLast6MonthsSummary() async {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final stats = await getMonthlyStats(date.year, date.month);
      result.add({
        'year': date.year,
        'month': date.month,
        'income': stats['income']!,
        'expense': stats['expense']!,
      });
    }

    return result;
  }
}
