import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/admin_service.dart';
import 'package:intl/intl.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  List<dynamic> transactions = [];
  bool _isLoading = true;
  String _selectedStatus = '';
  int _currentPage = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final result = await AdminService.getTransactions(
        status: _selectedStatus.isEmpty ? null : _selectedStatus,
        limit: 20,
        skip: _currentPage * 20,
      );

      setState(() {
        transactions = result?['data'] ?? [];
        _totalPages = result?['pages'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[600],
        title: const Text('Transaction History'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus.isEmpty
                              ? null
                              : _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('Completed'),
                            ),
                            DropdownMenuItem(
                              value: 'failed',
                              child: Text('Failed'),
                            ),
                            DropdownMenuItem(
                              value: 'refunded',
                              child: Text('Refunded'),
                            ),
                          ],
                          onChanged: (value) {
                            _currentPage = 0;
                            setState(() => _selectedStatus = value ?? '');
                            _loadTransactions();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _loadTransactions(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),

                // Summary Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Transactions',
                          transactions.length.toString(),
                          Colors.blue[600]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Amount',
                          _calculateTotal(),
                          Colors.green[600]!,
                        ),
                      ),
                    ],
                  ),
                ),

                // Transactions List
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                ),

                // Pagination
                if (_totalPages > 1)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentPage > 0
                              ? () {
                                  _currentPage--;
                                  _loadTransactions();
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                        Text(
                          'Page ${_currentPage + 1}/$_totalPages',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _currentPage < _totalPages - 1
                              ? () {
                                  _currentPage++;
                                  _loadTransactions();
                                }
                              : null,
                          label: const Text('Next'),
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  String _calculateTotal() {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction['status'] == 'completed') {
        total += (transaction['amount'] ?? 0).toDouble();
      }
    }
    return '\$${total.toStringAsFixed(2)}';
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final status = transaction['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final amount = transaction['amount'] ?? 0;
    final type = transaction['type'] ?? 'unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(_getStatusIcon(status), color: statusColor),
        ),
        title: Text(
          'Transaction #${transaction['_id']?.toString().substring(0, 8) ?? 'N/A'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Type: ${type.toUpperCase()}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(transaction['createdAt'] ?? DateTime.now().toString()))}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$$amount',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.cancel;
      case 'refunded':
        return Icons.undo;
      default:
        return Icons.info;
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'ID',
                transaction['_id']?.toString().substring(0, 12) ?? 'N/A',
              ),
              _buildDetailRow(
                'Type',
                transaction['type']?.toUpperCase() ?? 'N/A',
              ),
              _buildDetailRow(
                'Status',
                transaction['status']?.toUpperCase() ?? 'N/A',
              ),
              _buildDetailRow('Amount', '\$${transaction['amount'] ?? 0}'),
              _buildDetailRow(
                'Date',
                DateFormat('dd/MM/yyyy HH:mm').format(
                  DateTime.parse(
                    transaction['createdAt'] ?? DateTime.now().toString(),
                  ),
                ),
              ),
              if (transaction['description'] != null)
                _buildDetailRow('Description', transaction['description']),
              if (transaction['paymentMethod'] != null)
                _buildDetailRow('Payment Method', transaction['paymentMethod']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
