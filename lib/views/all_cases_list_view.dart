import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../theme/legal_theme.dart';
import '../viewmodels/case_viewmodel.dart';
import '../widgets/neumorphic.dart';
import 'case_detail_view.dart';
import 'add_edit_case_view.dart';

class AllCasesListView extends StatefulWidget {
  const AllCasesListView({super.key});

  @override
  State<AllCasesListView> createState() => _AllCasesListViewState();
}

class _AllCasesListViewState extends State<AllCasesListView> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Cases'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: NeuContainer(
              shape: NeuShape.pressed,
              radius: LegalRadius.lg,
              child: TextField(
                style: const TextStyle(color: LegalColors.textPrimary, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'Search cases...',
                  hintStyle: TextStyle(color: LegalColors.textMuted),
                  prefixIcon: Icon(Icons.search_rounded, color: LegalColors.textMuted),
                ),
                onChanged: (value) => setState(() => _searchText = value),
              ),
            ),
          ),
          Expanded(
            child: Consumer<CaseViewModel>(
              builder: (context, viewModel, child) {
                final filtered = viewModel.allCases.where((c) {
                  if (_searchText.isEmpty) return true;
                  final search = _searchText.toLowerCase();
                  return c.caseNumber.toLowerCase().contains(search) ||
                      c.caseName.toLowerCase().contains(search) ||
                      c.customerName.toLowerCase().contains(search);
                }).toList();

                if (filtered.isEmpty) {
                  return const NeuEmptyState(
                    icon: Icons.list_alt_rounded,
                    title: 'No Cases Found',
                    subtitle: 'Try adjusting your search query or add a new case',
                  );
                }

                final grouped = <String, List<LegalCase>>{};
                for (final c in filtered) {
                  final key = DateFormat('MMMM y').format(c.caseDate);
                  grouped.putIfAbsent(key, () => []).add(c);
                }

                return RefreshIndicator(
                  color: LegalColors.gold,
                  onRefresh: () => viewModel.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final month = grouped.keys.elementAt(index);
                      final cases = grouped[month]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 10),
                            child: Text(
                              month,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: LegalColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          ...cases.map((c) => _CaseRow(caseItem: c)),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: NeuContainer(
        shape: NeuShape.flat,
        radius: 28,
        padding: const EdgeInsets.all(14),
        color: LegalColors.surface,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditCaseView()),
          );
        },
        child: const Icon(
          Icons.add_rounded,
          color: LegalColors.gold,
          size: 30,
        ),
      ),
    );
  }
}

class _CaseRow extends StatelessWidget {
  final LegalCase caseItem;

  const _CaseRow({required this.caseItem});

  Color get _statusColor {
    switch (caseItem.status) {
      case 'completed':
        return LegalColors.emerald;
      case 'rescheduled':
        return LegalColors.amber;
      default:
        return LegalColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaseDetailView(caseItem: caseItem),
          ),
        );
      },
      child: Row(
        children: [
          NeuContainer(
            shape: NeuShape.pressed,
            radius: 14,
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.folder_rounded, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      caseItem.caseNumber,
                      style: const TextStyle(
                        color: LegalColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(LegalRadius.pill),
                        border: Border.all(color: _statusColor.withAlpha(40), width: 1),
                      ),
                      child: Text(
                        caseItem.status[0].toUpperCase() + caseItem.status.substring(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  caseItem.caseName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LegalColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 13, color: LegalColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      caseItem.customerName,
                      style: const TextStyle(fontSize: 12, color: LegalColors.textMuted),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today_rounded, size: 12, color: LegalColors.blue),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, y').format(caseItem.caseDate),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: LegalColors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
