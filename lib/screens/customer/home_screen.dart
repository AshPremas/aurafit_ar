import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import 'item_details_screen.dart';
import 'wishlist_screen.dart';

/// HomeScreen — Main catalog screen with category tabs and product grid.
/// Uses [DefaultTabController] for category-based filtering.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _categories = ['All', 'Tops', 'Bottoms', 'Dresses', 'Sarees'];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtered catalog based on selected category and search query ──────────
  List<ClothingItem> get _filteredItems {
    return mockClothingCatalog.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
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

  // ── AppBar ────────────────────────────────────────────────────────────────
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

  // ── Search Bar ────────────────────────────────────────────────────────────
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

  // ── Category Chips ────────────────────────────────────────────────────────
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

  // ── Product Grid ──────────────────────────────────────────────────────────
  Widget _buildProductGrid() {
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
      itemBuilder: (_, i) => _ProductCard(item: _filteredItems[i]),
    );
  }

  // ── Bottom Navigation Bar ─────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: kCardBgColor,
      selectedItemColor: kAccentColor,
      unselectedItemColor: kTextSecondaryColor,
      currentIndex: 0,
      onTap: (idx) {
        if (idx == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WishlistScreen()),
          );
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

// ─── Product Card Widget ─────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ClothingItem item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)),
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
                  color: Colors.white10,
                  width: double.infinity,
                  child: const Icon(
                    Icons.checkroom,
                    size: 60,
                    color: kAccentColor,
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
