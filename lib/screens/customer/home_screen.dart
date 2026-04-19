import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import 'item_details_screen.dart';
import 'wishlist_screen.dart';
import '../../services/api_service.dart';
import 'profile_screen.dart';

/// HomeScreen — Main catalog screen with category tabs and product grid.
class HomeScreen extends StatefulWidget {
  final int customerId;
final String customerName;
final String customerEmail;

const HomeScreen({
  super.key,
  required this.customerId,
  required this.customerName,
  required this.customerEmail,
});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = ['All', 'Tops', 'Bottoms', 'Dresses', 'Sarees'];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ClothingItem> _catalogItems = [];
  bool _isLoadingItems = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
      _searchController.clear();
      _searchQuery = '';
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await ApiService.instance.fetchItems();
    setState(() {
      _catalogItems = items;
      _isLoadingItems = false;
    });
  }

  //Filtered catalog based on selected category and search query
  List<ClothingItem> get _filteredItems {
    return  _catalogItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category.trim() == _selectedCategory.trim();
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  //AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kPrimaryDarkColor,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'AuraFit AR',
        style: TextStyle(
          color: kTextPrimaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.2,
        ),
      ),
      leading: const Icon(Icons.menu, color: kTextPrimaryColor),
    );
  }

  //Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black87),
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search Here',
          hintStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: kSearchBarColor,
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  //Category Chips
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              selectedColor: kAccentColor,
              backgroundColor: kCardBgColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : kTextSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  //Product Grid
  Widget _buildProductGrid() {
  if (_isLoadingItems) {
    return const Center(
      child: CircularProgressIndicator(
        color: kAccentColor,
      ),
    );
  }
  if (_filteredItems.isEmpty) {
    return Center(
      child: Text(
        'No items found',
          style: TextStyle(color: kTextSecondaryColor),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (_, i) => _ProductCard(item: _filteredItems[i], customerId: widget.customerId),
    );
  }

  //Bottom Navigation Bar
  Widget _buildBottomNav(BuildContext context) {
  return BottomNavigationBar(
    backgroundColor: kCardBgColor,
    selectedItemColor: kAccentColor,
    unselectedItemColor: kTextSecondaryColor,
    currentIndex: 0,
    onTap: (idx) {
      if (idx == 1) {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => WishlistScreen(
            customerId: widget.customerId)));
      } else if (idx == 2) {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProfileScreen(
            customerId: widget.customerId,
            customerName: widget.customerName,
            customerEmail: widget.customerEmail,
          )));
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
  );
}
}

//Product Card Widget
class _ProductCard extends StatelessWidget {
  final ClothingItem item;
  final int customerId;
  const _ProductCard({required this.item, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item, customerId: customerId)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: kCardBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Garment image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Image.asset(
                    item.imageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Name and price
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: kTextPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.formattedPrice,
                    style: const TextStyle(
                      color: kAccentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
