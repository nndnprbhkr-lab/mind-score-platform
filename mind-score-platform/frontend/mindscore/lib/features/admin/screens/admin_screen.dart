import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
            Tab(icon: Icon(Icons.quiz_outlined), text: 'Tests'),
            Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UsersTab(isDesktop: isDesktop),
          _TestsTab(isDesktop: isDesktop),
          _ReportsTab(isDesktop: isDesktop),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final bool isDesktop;

  const _UsersTab({required this.isDesktop});

  static final _users = [
    {'email': 'alice@example.com', 'role': 'User', 'tests': 8, 'avgScore': '82%'},
    {'email': 'bob@example.com', 'role': 'User', 'tests': 3, 'avgScore': '71%'},
    {'email': 'carol@example.com', 'role': 'Admin', 'tests': 15, 'avgScore': '90%'},
    {'email': 'dave@example.com', 'role': 'User', 'tests': 1, 'avgScore': '55%'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_users.length} Users',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Add User'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: _users.asMap().entries.map((e) {
                final i = e.key;
                final u = e.value;
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Text(
                          (u['email'] as String)[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(u['email'] as String),
                      subtitle: Text('${u['tests']} tests · Avg ${u['avgScore']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: u['role'] == 'Admin'
                                  ? AppColors.primary.withOpacity(0.12)
                                  : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              u['role'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: u['role'] == 'Admin'
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded, size: 18),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    if (i < _users.length - 1) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestsTab extends StatelessWidget {
  final bool isDesktop;

  const _TestsTab({required this.isDesktop});

  static final _tests = [
    {'title': 'Cognitive Aptitude', 'questions': 30, 'attempts': 47, 'avgScore': '76%'},
    {'title': 'Emotional Intelligence', 'questions': 20, 'attempts': 32, 'avgScore': '81%'},
    {'title': 'Critical Thinking', 'questions': 25, 'attempts': 18, 'avgScore': '68%'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_tests.length} Tests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Test'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._tests.map(
            (t) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  t['title'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${t['questions']} questions · ${t['attempts']} attempts · Avg ${t['avgScore']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () {}),
                    IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18,
                            color: AppColors.error),
                        onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final bool isDesktop;

  const _ReportsTab({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = [
      {'label': 'Total Users', 'value': '4', 'icon': Icons.people_outline, 'color': AppColors.primary},
      {'label': 'Total Tests', 'value': '3', 'icon': Icons.quiz_outlined, 'color': AppColors.secondary},
      {'label': 'Total Attempts', 'value': '97', 'icon': Icons.assignment_outlined, 'color': AppColors.success},
      {'label': 'Avg Score', 'value': '75%', 'icon': Icons.bar_chart_rounded, 'color': AppColors.warning},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 500 ? 2 : 1;
            final w = (constraints.maxWidth - (cols - 1) * 12) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: stats.map((s) {
                return SizedBox(
                  width: w,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (s['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(s['icon'] as IconData,
                                color: s['color'] as Color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['value'] as String,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                s['label'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
