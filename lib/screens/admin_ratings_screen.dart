import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/admin_service.dart';

class AdminRatingsScreen extends StatefulWidget {
  const AdminRatingsScreen({super.key});

  @override
  State<AdminRatingsScreen> createState() => _AdminRatingsScreenState();
}

class _AdminRatingsScreenState extends State<AdminRatingsScreen> {
  List<dynamic> ratings = [];
  bool _isLoading = true;
  int _minRating = 0;
  int _currentPage = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final result = await AdminService.getRatings(
        minRating: _minRating > 0 ? _minRating : null,
        limit: 20,
        skip: _currentPage * 20,
      );

      setState(() {
        ratings = result?['data'] ?? [];
        _totalPages = result?['pages'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading ratings: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[600],
        title: const Text('Moderate Ratings'),
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
                        child: DropdownButtonFormField<int>(
                          value: _minRating,
                          decoration: InputDecoration(
                            labelText: 'Min Rating',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('All')),
                            DropdownMenuItem(value: 1, child: Text('1+ Stars')),
                            DropdownMenuItem(value: 2, child: Text('2+ Stars')),
                            DropdownMenuItem(value: 3, child: Text('3+ Stars')),
                            DropdownMenuItem(value: 4, child: Text('4+ Stars')),
                            DropdownMenuItem(value: 5, child: Text('5 Stars')),
                          ],
                          onChanged: (value) {
                            _currentPage = 0;
                            setState(() => _minRating = value ?? 0);
                            _loadRatings();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _loadRatings(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),

                // Summary
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Ratings',
                          ratings.length.toString(),
                          Colors.blue[600]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Flagged',
                          _countFlagged().toString(),
                          Colors.red[600]!,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ratings List
                Expanded(
                  child: ratings.isEmpty
                      ? Center(
                          child: Text(
                            'No ratings found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: ratings.length,
                          itemBuilder: (context, index) {
                            final rating = ratings[index];
                            return _buildRatingCard(rating);
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
                                  _loadRatings();
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
                                  _loadRatings();
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

  int _countFlagged() {
    return ratings.where((r) => r['isFlagged'] == true).length;
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

  Widget _buildRatingCard(Map<String, dynamic> rating) {
    final ratingValue = rating['rating'] ?? 0;
    final isFlagged = rating['isFlagged'] ?? false;
    final review = rating['review'] ?? 'No review text';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isFlagged ? Colors.red[50] : null,
      child: ExpansionTile(
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < ratingValue ? Icons.star : Icons.star_outline,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'User ${rating['ratedUserId']?.toString().substring(0, 8) ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            if (isFlagged)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'FLAGGED',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(review, style: TextStyle(color: Colors.grey[700])),
                if (rating['categories'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Category Ratings:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...(rating['categories'] as Map<String, dynamic>?)
                              ?.entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key),
                                      Text(
                                        '${entry.value}/5',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList() ??
                          [],
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleFlag(rating),
                        icon: Icon(
                          isFlagged ? Icons.flag_outlined : Icons.flag,
                        ),
                        label: Text(isFlagged ? 'Unflag' : 'Flag'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFlagged
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDetails(rating),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlag(Map<String, dynamic> rating) async {
    final isFlagged = rating['isFlagged'] ?? false;
    final success = await AdminService.toggleRatingFlag(
      rating['_id'],
      !isFlagged,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rating ${isFlagged ? 'unflagged' : 'flagged'} successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadRatings();
    }
  }

  void _showDetails(Map<String, dynamic> rating) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rating Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Rating ID',
                rating['_id']?.toString().substring(0, 12) ?? 'N/A',
              ),
              _buildDetailRow('Rating', '${rating['rating']}/5'),
              _buildDetailRow(
                'Rated User',
                rating['ratedUserId']?.toString().substring(0, 8) ?? 'N/A',
              ),
              _buildDetailRow(
                'Rater ID',
                rating['raterId']?.toString().substring(0, 8) ?? 'N/A',
              ),
              _buildDetailRow(
                'Flagged',
                rating['isFlagged'] == true ? 'Yes' : 'No',
              ),
              const SizedBox(height: 12),
              const Text(
                'Review:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(rating['review'] ?? 'No review'),
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
