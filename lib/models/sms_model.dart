class SmsModel {
  final int id;
  final String number;
  final String message;
  final String status;
  final DateTime dateTime;

  SmsModel({
    required this.id,
    required this.number,
    required this.message,
    required this.status,
    required this.dateTime,
  });

  factory SmsModel.fromJson(Map<String, dynamic> json) {
    return SmsModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      number: json['number']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      dateTime: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  bool get isDelivered => status.toLowerCase() == 'delivered' || status.toLowerCase() == 'sent';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get isPending => status.toLowerCase() == 'pending';
}