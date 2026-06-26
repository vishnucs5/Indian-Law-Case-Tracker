import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../theme/legal_theme.dart';
import '../viewmodels/case_viewmodel.dart';
import '../widgets/neumorphic.dart';

class AddEditCaseView extends StatefulWidget {
  final LegalCase? existingCase;

  const AddEditCaseView({super.key, this.existingCase});

  @override
  State<AddEditCaseView> createState() => _AddEditCaseViewState();
}

class _AddEditCaseViewState extends State<AddEditCaseView> {
  final _formKey = GlobalKey<FormState>();
  final _caseNumberController = TextEditingController();
  final _caseNameController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();

  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  bool get isEditing => widget.existingCase != null;

  @override
  void initState() {
    super.initState();
    final initialDate = widget.existingCase?.caseDate ?? DateTime.now();
    _selectedDay = initialDate.day;
    _selectedMonth = initialDate.month;
    _selectedYear = initialDate.year;
    if (isEditing) {
      _caseNumberController.text = widget.existingCase!.caseNumber;
      _caseNameController.text = widget.existingCase!.caseName;
      _customerNameController.text = widget.existingCase!.customerName;
      _notesController.text = widget.existingCase!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _caseNumberController.dispose();
    _caseNameController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final caseDate = _buildDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Case' : 'New Case'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 6, bottom: 6),
            child: NeuContainer(
              shape: NeuShape.flat,
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              onTap: () => _save(caseDate),
              child: Center(
                child: Text(
                  isEditing ? 'Save' : 'Add',
                  style: const TextStyle(
                    color: LegalColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const NeuSectionTitle(title: 'Case Details'),
            NeuContainer(
              shape: NeuShape.pressed,
              child: TextFormField(
                controller: _caseNumberController,
                decoration: const InputDecoration(labelText: 'Case Number'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 12),
            NeuContainer(
              shape: NeuShape.pressed,
              child: TextFormField(
                controller: _caseNameController,
                decoration: const InputDecoration(labelText: 'Case Name'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 12),
            NeuContainer(
              shape: NeuShape.pressed,
              child: TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Client Name'),
              ),
            ),
            const NeuSectionTitle(title: 'Hearing Date'),
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
            const NeuSectionTitle(title: 'Notes'),
            NeuContainer(
              shape: NeuShape.pressed,
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dates can be today or later.',
              style: TextStyle(color: LegalColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _save(DateTime caseDate) {
    if (!_formKey.currentState!.validate()) return;

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    if (caseDate.isBefore(startOfToday)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date must be today or later')),
      );
      return;
    }

    final viewModel = context.read<CaseViewModel>();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (isEditing) {
      viewModel.updateCase(
        widget.existingCase!,
        caseNumber: _caseNumberController.text.trim(),
        caseName: _caseNameController.text.trim(),
        customerName: _customerNameController.text.trim(),
        caseDate: caseDate,
        notes: notes,
      );
    } else {
      viewModel.addCase(
        caseNumber: _caseNumberController.text.trim(),
        caseName: _caseNameController.text.trim(),
        customerName: _customerNameController.text.trim(),
        caseDate: caseDate,
        notes: notes,
      );
    }

    Navigator.pop(context);
  }
}
