import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../theme/legal_theme.dart';
import '../viewmodels/case_viewmodel.dart';
import '../widgets/neumorphic.dart';
import 'add_edit_case_view.dart';
import 'reschedule_sheet_view.dart';

class CaseDetailView extends StatelessWidget {
  final LegalCase caseItem;

  const CaseDetailView({super.key, required this.caseItem});

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
    return Selector<CaseViewModel, LegalCase>(
      selector: (context, vm) => vm.allCases.firstWhere(
        (c) => c.id == caseItem.id,
        orElse: () => caseItem,
      ),
      builder: (context, currentCase, child) {
        final isUpcoming = currentCase.status == 'upcoming';

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
              child: NeuIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
            ),
            title: const Text('Case Details'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: NeuIconButton(
                  icon: Icons.edit_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditCaseView(existingCase: currentCase),
                      ),
                    );
                  },
                  tooltip: 'Edit Case',
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // Main Card
              NeuContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NeuContainer(
                          shape: NeuShape.pressed,
                          radius: 12,
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.gavel_rounded, color: _statusColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentCase.caseNumber,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: LegalColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Client: ${currentCase.customerName}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: LegalColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(LegalRadius.pill),
                            border: Border.all(color: _statusColor.withAlpha(50), width: 1),
                          ),
                          child: Text(
                            currentCase.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: LegalColors.borderLight),
                    Text(
                      currentCase.caseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: LegalColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: LegalColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          'Hearing Date: ',
                          style: TextStyle(fontSize: 14, color: LegalColors.textMuted),
                        ),
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(currentCase.caseDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: LegalColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Notes section
              const NeuSectionTitle(title: 'Case Notes'),
              NeuContainer(
                padding: const EdgeInsets.all(16),
                child: Text(
                  (currentCase.notes == null || currentCase.notes!.isEmpty)
                      ? 'No notes added for this case.'
                      : currentCase.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: (currentCase.notes == null || currentCase.notes!.isEmpty)
                        ? LegalColors.textMuted
                        : LegalColors.textPrimary,
                    fontStyle: (currentCase.notes == null || currentCase.notes!.isEmpty)
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reschedule Timeline
              if (currentCase.rescheduleHistory.isNotEmpty) ...[
                const NeuSectionTitle(title: 'Reschedule History'),
                NeuContainer(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentCase.rescheduleHistory.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 24,
                      color: LegalColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final event = currentCase.rescheduleHistory[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const NeuContainer(
                            shape: NeuShape.pressed,
                            radius: 8,
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.history_rounded, size: 16, color: LegalColors.amber),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rescheduled on ${DateFormat('MMM d, y').format(event.changedAt)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: LegalColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Changed from ${DateFormat('MMM d, y').format(event.oldDate)} to ${DateFormat('MMM d, y').format(event.newDate)}',
                                  style: const TextStyle(fontSize: 12, color: LegalColors.textPrimary),
                                ),
                                if (event.reason != null && event.reason!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reason: "${event.reason}"',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: LegalColors.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Actions
              const NeuSectionTitle(title: 'Actions'),
              if (isUpcoming) ...[
                Row(
                  children: [
                    Expanded(
                      child: NeuButton(
                        onTap: () async {
                          final confirm = await _showConfirmDialog(
                            context,
                            title: 'Complete Case',
                            content: 'Are you sure you want to mark this case as completed?',
                          );
                          if (confirm == true && context.mounted) {
                            await context.read<CaseViewModel>().markCompleted(currentCase);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Case marked as completed')),
                              );
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_rounded, color: LegalColors.emerald, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Completed',
                              style: TextStyle(
                                color: LegalColors.emerald,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeuButton(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => RescheduleSheetView(caseItem: currentCase),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.calendar_month_rounded, color: LegalColors.amber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Reschedule',
                              style: TextStyle(
                                color: LegalColors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              NeuButton(
                onTap: () async {
                  final confirm = await _showConfirmDialog(
                    context,
                    title: 'Delete Case',
                    content: 'This action is permanent and cannot be undone. Are you sure?',
                    isDestructive: true,
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<CaseViewModel>().deleteCase(currentCase);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Case deleted successfully')),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Delete Case Record',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: LegalColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegalRadius.lg),
        ),
        title: Text(
          title,
          style: const TextStyle(color: LegalColors.textPrimary, fontWeight: FontWeight.w800),
        ),
        content: Text(
          content,
          style: const TextStyle(color: LegalColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: LegalColors.textMuted, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.redAccent : LegalColors.textPrimary,
            ),
            child: Text(
              isDestructive ? 'Delete' : 'Confirm',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
