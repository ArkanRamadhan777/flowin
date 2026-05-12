import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/loading_overlay.dart';

/// Format angka dengan titik sebagai pemisah ribuan: 1000000 → 1.000.000
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    // Validate only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return oldValue;
    final formatted = _addSeparators(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _addSeparators(String digits) {
    final buffer = StringBuffer();
    final len = digits.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String format(String raw) => _addSeparators(raw.replaceAll('.', ''));
}

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  late String _type;
  late String _category;
  late DateTime _date;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _titleController.text = tx.title;
      _amountController.text =
          _ThousandsSeparatorFormatter.format(tx.amount.toStringAsFixed(0));
      _type = tx.type;
      _category = tx.category;
      _date = tx.date;
    } else {
      _type = 'expense';
      _category = AppStrings.kategorisPengeluaran.first;
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId =
          ref.read(authNotifierProvider).valueOrNull?.id ?? '';

      final amount =
          double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

      if (_isEditing) {
        final updated = widget.transaction!.copyWith(
          title: _titleController.text.trim(),
          amount: amount,
          type: _type,
          category: _category,
          date: _date,
        );
        await ref.read(transactionListProvider.notifier).edit(updated);
      } else {
        final transaction = TransactionModel(
          id: const Uuid().v4(),
          userId: userId,
          title: _titleController.text.trim(),
          amount: amount,
          type: _type,
          category: _category,
          date: _date,
          createdAt: DateTime.now(),
        );
        await ref.read(transactionListProvider.notifier).create(transaction);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Transaksi berhasil diperbarui'
                  : 'Transaksi berhasil ditambahkan',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.cardBackground,
          ),
          dialogBackgroundColor: AppColors.cardBackground,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? AppStrings.editTransaksi : AppStrings.tambahTransaksi,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.expense),
                onPressed: _confirmDelete,
                tooltip: 'Hapus',
              ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ScrollConfiguration(
              behavior:
                  const ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Type selector
                    _TypeSelector(
                      type: _type,
                      onChanged: (v) => setState(() {
                        _type = v;
                        // Reset kategori ke default list yang sesuai
                        _category = v == 'income'
                            ? AppStrings.kategorisPemasukan.first
                            : AppStrings.kategorisPengeluaran.first;
                      }),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: AppStrings.judul,
                        prefixIcon: Icon(Icons.title_rounded,
                            color: AppColors.textMuted, size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppStrings.judulWajibDiisi;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        _ThousandsSeparatorFormatter(),
                      ],
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: AppStrings.jumlah,
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(Icons.payments_outlined,
                            color: AppColors.textMuted, size: 20),
                      ),
                      validator: (v) {
                        final raw = (v ?? '').replaceAll('.', '');
                        final val = double.tryParse(raw);
                        if (val == null || val <= 0) {
                          return AppStrings.jumlahHarusLebihDariNol;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      value: _category,
                      dropdownColor: AppColors.cardBackground,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                      ),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        labelText: AppStrings.kategori,
                        prefixIcon: Icon(Icons.category_outlined,
                            color: AppColors.textMuted, size: 20),
                      ),
                      items: (_type == 'income'
                              ? AppStrings.kategorisPemasukan
                              : AppStrings.kategorisPengeluaran)
                          .map(
                            (k) => DropdownMenuItem(
                              value: k,
                              child: Text(k),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return AppStrings.kategoriWajibDipilih;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Date picker
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppStrings.tanggal,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_date.day}/${_date.month}/${_date.year}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Save button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Text(
                        _isEditing ? AppStrings.simpan : AppStrings.tambah,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.hapusTransaksi),
        content: const Text(AppStrings.pesanHapus),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text(AppStrings.hapus),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(transactionListProvider.notifier)
            .delete(widget.transaction!.id);
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus transaksi')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

class _TypeSelector extends StatelessWidget {
  final String type;
  final ValueChanged<String> onChanged;

  const _TypeSelector({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: AppStrings.pengeluaran,
              icon: Icons.arrow_upward_rounded,
              selected: type == 'expense',
              selectedColor: AppColors.expense,
              onTap: () => onChanged('expense'),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: AppStrings.pemasukan,
              icon: Icons.arrow_downward_rounded,
              selected: type == 'income',
              selectedColor: AppColors.income,
              onTap: () => onChanged('income'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? selectedColor : AppColors.textMuted,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? selectedColor : AppColors.textMuted,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
