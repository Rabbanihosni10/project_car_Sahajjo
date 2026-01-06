class PaymentSession {
  final String transactionId;
  final String tranId;
  final String gatewayUrl;

  PaymentSession({
    required this.transactionId,
    required this.tranId,
    required this.gatewayUrl,
  });

  factory PaymentSession.fromJson(Map<String, dynamic> json) {
    return PaymentSession(
      transactionId: json['transactionId'] as String,
      tranId: json['tranId'] as String,
      gatewayUrl: json['gatewayUrl'] as String,
    );
  }
}
