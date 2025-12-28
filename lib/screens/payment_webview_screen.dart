import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cars_ahajjo/services/payment_service.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String gatewayUrl;
  final String transactionId;
  final String? baseUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.gatewayUrl,
    required this.transactionId,
    this.baseUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _loading = true);
          },
          onPageFinished: (url) async {
            setState(() => _loading = false);
            if (url.contains('/api/payments/ssl/success')) {
              _finishWithStatus('completed');
            } else if (url.contains('/api/payments/ssl/fail')) {
              _finishWithStatus('failed');
            } else if (url.contains('/api/payments/ssl/cancel')) {
              _finishWithStatus('cancelled');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.gatewayUrl));
  }

  Future<void> _finishWithStatus(String status) async {
    try {
      final tx = await PaymentService.getTransaction(
        transactionId: widget.transactionId,
        baseUrl: widget.baseUrl,
      );
      if (!mounted) return;
      Navigator.of(context).pop({'status': status, 'transaction': tx});
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop({'status': status});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
