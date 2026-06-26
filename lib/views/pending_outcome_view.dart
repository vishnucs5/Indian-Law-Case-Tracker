import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/case_viewmodel.dart';
import '../widgets/neumorphic.dart';
import '../theme/legal_theme.dart';
import 'reschedule_sheet_view.dart';

class PendingOutcomeView extends StatelessWidget {
  const PendingOutcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Outcomes'),
        centerTitle: true,
      ),
      body: Consumer<CaseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.pendingOutcomes.isEmpty) {
            return const NeuEmptyState(
              icon: Icons.check_circle_rounded,
              title: 'All Clear',
              subtitle: 'No pending outcomes to resolve',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            itemCount: viewModel.pendingOutcomes.length,
            itemBuilder: (context, index) {
              final caseItem = viewModel.pendingOutcomes[index];
              return NeuContainer(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const NeuContainer(
                          shape: NeuShape.pressed,
                          radius: 10,
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.help_outline_rounded, color: LegalColors.gold, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            caseItem.caseNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: LegalColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      caseItem.caseName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: LegalColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scheduled Date: ${caseItem.caseDate.day}/${caseItem.caseDate.month}/${caseItem.caseDate.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: LegalColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NeuButton(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            onTap: () => viewModel.markCompleted(caseItem),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check_circle_outline_rounded, color: LegalColors.emerald, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: LegalColors.emerald,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: NeuButton(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => RescheduleSheetView(caseItem: caseItem),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.calendar_month_outlined, color: LegalColors.amber, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Rescheduled',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: LegalColors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
