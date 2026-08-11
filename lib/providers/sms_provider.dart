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
    if (token == null) return; //

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await ApiService.getLatestSms(token, limit: 5);
      state = state.copyWith(smsList: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'SMS Unable to Load.');
    }
  }
}

final smsProvider = StateNotifierProvider<SmsNotifier, SmsState>((ref) {
  return SmsNotifier(ref);
});