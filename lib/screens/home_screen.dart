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
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final sms = ref.watch(smsProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.username ?? ''}'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(smsProvider.notifier).fetchLatestSms(),
        child: _buildBody(sms),
      ),
    );
  }

  Widget _buildBody(SmsState sms) {
    if (sms.isLoading && sms.smsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sms.errorMessage != null && sms.smsList.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(child: Text(sms.errorMessage!)),
        ],
      );
    }

    if (sms.smsList.isEmpty) {
      return const Center(child: Text('No SMS to show.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sms.smsList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _SmsCard(sms: sms.smsList[index]),
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

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(sms.dateTime);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(sms.number, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(sms.status, style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(sms.message, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}