import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sms_model.dart';
import '../services/api_service.dart';
import 'auth_providers.dart';

class SmsState {
  final List<SmsModel> smsList;
  final bool isLoading;
  final String? errorMessage;

  const SmsState({
    this.smsList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SmsState copyWith({
    List<SmsModel>? smsList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SmsState(
      smsList: smsList ?? this.smsList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SmsNotifier extends StateNotifier<SmsState> {
  final Ref ref;
  SmsNotifier(this.ref) : super(const SmsState());

  Future<void> fetchLatestSms() async {
    final token = ref.read(authProvider).user?.token;
    
    // If we don't have a token, we can still show dummy data for testing
    // or just return if authentication is strictly required.
    
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // We pass token even if it's dummy for now
      final list = await ApiService.getLatestSms(token ?? 'dummy_token', limit: 5);
      state = state.copyWith(smsList: list, isLoading: false);
    } catch (e) {
      debugPrint('Error fetching SMS: $e');
      state = state.copyWith(
        isLoading: false, 
        errorMessage: 'Could not load messages. Showing dummy data instead.'
      );
      
      // Fallback to dummy data even on error so the user sees something
      _loadDummyData();
    }
  }

  void _loadDummyData() {
    final dummyList = [
      SmsModel(
        id: 1,
        number: '03001234567',
        message: 'Dummy: Your OTP is 4521.',
        status: 'delivered',
        dateTime: DateTime.now(),
      ),
    ];
    state = state.copyWith(smsList: dummyList, isLoading: false);
  }
}

final smsProvider = StateNotifierProvider<SmsNotifier, SmsState>((ref) {
  return SmsNotifier(ref);
});
