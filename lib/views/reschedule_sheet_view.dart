import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../theme/legal_theme.dart';
import '../viewmodels/case_viewmodel.dart';
import '../widgets/neumorphic.dart';

class RescheduleSheetView extends StatefulWidget {
  final LegalCase caseItem;

  const RescheduleSheetView({super.key, required this.caseItem});

  @override
  State<RescheduleSheetView> createState() => _RescheduleSheetViewState();
}

class _RescheduleSheetViewState extends State<RescheduleSheetView> {
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;
  final _reasonController = TextEditingController();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.caseItem.caseDate.day;
    _selectedMonth = widget.caseItem.caseDate.month;
    _selectedYear = widget.caseItem.caseDate.year;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  DateTime _buildDate() {
    final now = DateTime.now();
    final year = _selectedYear.clamp(now.year, now.year + 5);
    final month = _selectedMonth.clamp(1, 12);
    final maxDay = _daysInMonth(year, month);
    final day = _selectedDay.clamp(1, maxDay);
    return DateTime(year, month, day);
  }

  int _daysInMonth(int year, int month) {
    if (month == 12) return 31;
    return DateTime(year, month + 1, 0).day;
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final newDate = _buildDate();

    return Container(
      decoration: const BoxDecoration(
        color: LegalColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: LegalColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Reschedule Case',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: LegalColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current Date: ${widget.caseItem.caseDate.day}/${widget.caseItem.caseDate.month}/${widget.caseItem.caseDate.year}',
            style: const TextStyle(fontSize: 14, color: LegalColors.textMuted),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: NeuContainer(
                  shape: NeuShape.pressed,
                  child: InputDecorator(
                    decoration: _dec('Day'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedDay,
                        isDense: true,
                        dropdownColor: LegalColors.background,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDay = val);
                        },
                        items: List.generate(31, (i) => i + 1)
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeuContainer(
                  shape: NeuShape.pressed,
                  child: InputDecorator(
                    decoration: _dec('Month'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedMonth,
                        isDense: true,
                        dropdownColor: LegalColors.background,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedMonth = val;
                              final maxDay = _daysInMonth(_selectedYear, val);
                              if (_selectedDay > maxDay) _selectedDay = maxDay;
                            });
                          }
                        },
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(_months[m - 1]),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeuContainer(
                  shape: NeuShape.pressed,
                  child: InputDecorator(
                    decoration: _dec('Year'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        isDense: true,
                        dropdownColor: LegalColors.background,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedYear = val;
                              final maxDay = _daysInMonth(val, _selectedMonth);
                              if (_selectedDay > maxDay) _selectedDay = maxDay;
                            });
                          }
                        },
                        items: List.generate(6, (i) => now.year + i)
                            .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NeuContainer(
            shape: NeuShape.pressed,
            child: TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rescheduling (Optional)',
              ),
            ),
          ),
          const SizedBox(height: 24),
          NeuButton(
            color: LegalColors.textPrimary,
            onTap: () {
              final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
              if (newDate.isBefore(tomorrow)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reschedule date must be tomorrow or later')),
                );
                return;
              }
              final viewModel = context.read<CaseViewModel>();
              viewModel.rescheduleCase(
                widget.caseItem,
                newDate,
                reason: _reasonController.text.trim().isEmpty
                    ? null
                    : _reasonController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Confirm Reschedule',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
