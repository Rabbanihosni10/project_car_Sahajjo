import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/search_service.dart';

class SearchScreen extends StatefulWidget {
  final String searchType; // 'drivers', 'owners', 'garages'

  const SearchScreen({super.key, this.searchType = 'drivers'});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> results = [];
  bool _isSearching = false;
  bool _showFilters = false;

  // Filter options
  String? _selectedExperience;
  String? _selectedVehicleType;
  final List<String> vehicleTypes = ['Car', 'Truck', 'Van', 'Bike'];
  final List<String> experienceLevels = ['1', '2', '3', '5', '10'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() => results = []);
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      List<dynamic> searchResults = [];

      if (widget.searchType == 'drivers') {
        if (_selectedExperience != null || _selectedVehicleType != null) {
          searchResults = await SearchService.filterDrivers(
            yearsOfExperience: _selectedExperience,
            vehicleType: _selectedVehicleType,
          );
        } else {
          searchResults = await SearchService.searchDrivers(
            _searchController.text,
          );
        }
      } else if (widget.searchType == 'owners') {
        searchResults = await SearchService.searchOwners(
          _searchController.text,
        );
      } else if (widget.searchType == 'garages') {
        searchResults = await SearchService.searchGarages(
          _searchController.text,
        );
      }

      setState(() {
        results = searchResults;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Text(
          'Search ${widget.searchType.replaceFirst(widget.searchType[0], widget.searchType[0].toUpperCase())}',
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.searchType == 'drivers'
                        ? 'Search by name, email, or phone'
                        : widget.searchType == 'owners'
                        ? 'Search by company or name'
                        : 'Search by garage name',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => results = []);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (widget.searchType == 'drivers' ||
                        widget.searchType == 'garages')
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _showFilters = !_showFilters);
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text('Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Filters section (if applicable)
          if (_showFilters && widget.searchType == 'drivers')
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _selectedVehicleType,
                    hint: const Text('Select Vehicle Type'),
                    isExpanded: true,
                    items: vehicleTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedVehicleType = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _selectedExperience,
                    hint: const Text('Select Years of Experience'),
                    isExpanded: true,
                    items: experienceLevels
                        .map(
                          (exp) => DropdownMenuItem(
                            value: exp,
                            child: Text('$exp+ Years'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedExperience = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedVehicleType = null;
                            _selectedExperience = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                        ),
                        child: const Text('Clear'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _performSearch();
                          setState(() => _showFilters = false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Start searching...'
                            : 'No results found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return _buildResultCard(result);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(dynamic result) {
    String title = '';
    String subtitle = '';
    String trailingText = '';

    if (widget.searchType == 'drivers') {
      title = result['name'] ?? 'Unknown Driver';
      subtitle =
          'Vehicle: ${result['vehicleType'] ?? 'N/A'} • Exp: ${result['yearsOfExperience'] ?? 'N/A'} yrs';
      trailingText = result['phone'] ?? '';
    } else if (widget.searchType == 'owners') {
      title = result['companyName'] ?? result['name'] ?? 'Unknown Owner';
      subtitle =
          'Type: ${result['businessType'] ?? 'N/A'} • Cars: ${result['numberOfCars'] ?? 'N/A'}';
      trailingText = result['phone'] ?? '';
    } else if (widget.searchType == 'garages') {
      title = result['name'] ?? 'Unknown Garage';
      subtitle = result['address'] ?? 'No address';
      trailingText = result['phone'] ?? '';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[600],
          child: Text(
            (title.isNotEmpty ? title[0] : 'U').toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (trailingText.isNotEmpty)
              Text(
                trailingText,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Opening profile for $title')));
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
