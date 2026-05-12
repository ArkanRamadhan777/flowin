import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/transaction_model.dart';
import 'repository_providers.dart';

// Filter type for transaction list
enum TransactionFilter { all, income, expense }

// Selected filter provider
final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) => TransactionFilter.all);

// Transaction list provider
final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<TransactionModel>>(
      () => TransactionListNotifier(),
    );

class TransactionListNotifier
    extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    return _fetchTransactions(null);
  }

  Future<List<TransactionModel>> _fetchTransactions(String? type) async {
    final repo = ref.read(transactionRepositoryProvider);
    return repo.getTransactions(type: type);
  }

  Future<void> refresh({String? type}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTransactions(type));
  }

  Future<void> create(TransactionModel transaction) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.createTransaction(transaction);
    _invalidateSummaries();
    await refresh();
  }

  Future<void> edit(TransactionModel transaction) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.updateTransaction(transaction);
    _invalidateSummaries();
    await refresh();
  }

  Future<void> delete(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.deleteTransaction(id);
    _invalidateSummaries();
    await refresh();
  }

  void _invalidateSummaries() {
    ref.invalidate(last6MonthsSummaryProvider);
    ref.invalidate(monthlyStatsProvider);
  }
}

// Filtered transactions provider (derived from list + filter)
final filteredTransactionProvider =
    Provider<AsyncValue<List<TransactionModel>>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  final listAsync = ref.watch(transactionListProvider);

  return listAsync.whenData((list) {
    switch (filter) {
      case TransactionFilter.income:
        return list.where((t) => t.isIncome).toList();
      case TransactionFilter.expense:
        return list.where((t) => t.isExpense).toList();
      case TransactionFilter.all:
        return list;
    }
  });
});

// Monthly stats provider
final monthlyStatsProvider =
    FutureProvider.family<Map<String, double>, ({int year, int month})>(
  (ref, params) async {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getMonthlyStats(params.year, params.month);
  },
);

// 6 months summary provider
final last6MonthsSummaryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getLast6MonthsSummary();
});

// Current month stats (derived)
final currentMonthStatsProvider = Provider<AsyncValue<Map<String, double>>>(
  (ref) {
    final now = DateTime.now();
    return ref.watch(
      monthlyStatsProvider((year: now.year, month: now.month)),
    );
  },
);
