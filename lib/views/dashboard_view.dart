import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../theme/legal_theme.dart';
import '../viewmodels/case_viewmodel.dart';
import '../widgets/neumorphic.dart';
import 'case_detail_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<CaseViewModel>(
          builder: (context, viewModel, child) {
            return RefreshIndicator(
              color: LegalColors.gold,
              onRefresh: () => viewModel.refresh(),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 110),
                children: [
                  const _Header(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.work_history_rounded,
                            label: 'Active Cases',
                            value: '${viewModel.activeCasesCount}',
                            color: LegalColors.teal,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.event_available_rounded,
                            label: '7-Day Hearings',
                            value: '${viewModel.upcomingHearingsCount}',
                            color: LegalColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  NeuSectionTitle(
                    title: "Today's Hearings",
                    trailing: '${viewModel.todaysCases.length}',
                  ),
                  if (viewModel.todaysCases.isEmpty)
                    const _InlineEmpty(message: 'No hearings today')
                  else
                    ...viewModel.todaysCases.map((c) => _CaseTile(caseItem: c)),
                  NeuSectionTitle(
                    title: "Tomorrow's Hearings",
                    trailing: '${viewModel.tomorrowsCases.length}',
                  ),
                  if (viewModel.tomorrowsCases.isEmpty)
                    const _InlineEmpty(message: 'No hearings tomorrow')
                  else
                    ...viewModel.tomorrowsCases.map((c) => _CaseTile(caseItem: c)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: NeuContainer(
        radius: LegalRadius.xl,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            NeuContainer(
              shape: NeuShape.pressed,
              radius: 22,
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CaseTrack',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: LegalColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Court dates, outcomes, and reminders',
                    style: TextStyle(color: LegalColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeuContainer(
            shape: NeuShape.pressed,
            radius: 16,
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: LegalColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: LegalColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  final String message;

  const _InlineEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      shape: NeuShape.pressed,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(message, style: const TextStyle(color: LegalColors.textMuted)),
      ),
    );
  }
}

class _CaseTile extends StatelessWidget {
  final LegalCase caseItem;

  const _CaseTile({required this.caseItem});

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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CaseDetailView(caseItem: caseItem)),
        );
      },
      child: Row(
        children: [
          NeuContainer(
            shape: NeuShape.pressed,
            radius: 16,
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.gavel_rounded, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseItem.caseNumber,
                  style: const TextStyle(
                    color: LegalColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(caseItem.caseName, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM d, y').format(caseItem.caseDate),
                  style: const TextStyle(color: LegalColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: LegalColors.textMuted),
        ],
      ),
    );
  }
}
