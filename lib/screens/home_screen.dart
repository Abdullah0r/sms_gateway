import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_providers.dart';
import '../providers/sms_provider.dart';
import '../models/sms_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(smsProvider.notifier).fetchLatestSms());
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sms = ref.watch(smsProvider);
    final user = ref.watch(authProvider).user;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(
              'Welcome back, ${user?.username ?? 'User'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Colors.grey[700]),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(smsProvider.notifier).fetchLatestSms(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildStatsHeader(sms.smsList),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      'Recent Messages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => ref.read(smsProvider.notifier).fetchLatestSms(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
            _buildBody(sms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(List<SmsModel> list) {
    int sent = list.where((s) => s.isDelivered).length;
    int failed = list.where((s) => s.isFailed).length;
    int pending = list.where((s) => s.isPending).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatCard(title: 'Sent', count: sent.toString(), color: Colors.green, icon: Icons.check_circle_outline),
          const SizedBox(width: 12),
          _StatCard(title: 'Failed', count: failed.toString(), color: Colors.red, icon: Icons.error_outline),
          const SizedBox(width: 12),
          _StatCard(title: 'Pending', count: pending.toString(), color: Colors.orange, icon: Icons.hourglass_empty),
        ],
      ),
    );
  }

  Widget _buildBody(SmsState sms) {
    if (sms.isLoading && sms.smsList.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (sms.errorMessage != null && sms.smsList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(sms.errorMessage!, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(smsProvider.notifier).fetchLatestSms(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (sms.smsList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sms_failed_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No messages found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: _SmsCard(sms: sms.smsList[index]),
          );
        },
        childCount: sms.smsList.length,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SmsCard extends StatelessWidget {
  final SmsModel sms;
  const _SmsCard({required this.sms});

  Color get _statusColor {
    if (sms.isDelivered) return Colors.green;
    if (sms.isFailed) return Colors.red;
    return Colors.orange;
  }

  IconData get _statusIcon {
    if (sms.isDelivered) return Icons.done_all;
    if (sms.isFailed) return Icons.close;
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM, hh:mm a').format(sms.dateTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _statusColor.withOpacity(0.1),
                radius: 18,
                child: Icon(_statusIcon, color: _statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sms.number,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sms.status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sms.message,
            style: TextStyle(color: Colors.grey[800], height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
