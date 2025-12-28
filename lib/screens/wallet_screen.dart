import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/payment_service.dart';
import 'package:cars_ahajjo/screens/payment_webview_screen.dart';

class WalletScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const WalletScreen({super.key, this.userData});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double walletBalance = 0;
  List<dynamic> transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      final balance = await PaymentService.getWalletBalance();
      final trans = await PaymentService.getTransactionHistory();

      setState(() {
        walletBalance = balance;
        transactions = trans;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading wallet data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    return 'TK ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          'Wallet & Earnings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Wallet Balance Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Earnings',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatCurrency(walletBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Withdrawal feature coming soon',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.send),
                                label: const Text('Withdraw'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue[600],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final session =
                                        await PaymentService.createSslCommerzSession(
                                          amount: 100.0,
                                          description: 'Wallet Top-up',
                                        );
                                    // Navigate to gateway
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaymentWebViewScreen(
                                          gatewayUrl: session.gatewayUrl,
                                          transactionId: session.transactionId,
                                        ),
                                      ),
                                    );
                                    if (!mounted) return;
                                    final status =
                                        (result as Map?)?['status'] ??
                                        'unknown';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Payment $status'),
                                      ),
                                    );
                                    // Refresh wallet on completion
                                    if (status == 'completed') {
                                      _loadWalletData();
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Payment error: $e'),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Top-up'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction History
                  const Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final trans = transactions[index];
                        final isCredit =
                            trans['transactionType'] == 'driver_earning' ||
                            trans['transactionType'] == 'wallet_topup';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCredit
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              child: Icon(
                                isCredit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isCredit ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              trans['description'] ??
                                  trans['transactionType'] ??
                                  'Transaction',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(_formatDate(trans['createdAt'])),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isCredit ? '+' : '-'} ${_formatCurrency(trans['amount'].toDouble())}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCredit ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(trans['status']),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    trans['status'] ?? 'pending',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'failed':
        return Colors.red[600]!;
      case 'refunded':
        return Colors.blue[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
