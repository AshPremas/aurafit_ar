import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import '../../services/api_service.dart';
import 'try_on_screen.dart';

/// ItemDetailsScreen — Displays full details of a selected [ClothingItem].
/// Allows size selection, adding to wishlist, and launching the AR try-on.
class ItemDetailsScreen extends StatefulWidget {
  final ClothingItem item;
  final int customerId;
  const ItemDetailsScreen({
    super.key, 
    required this.item,
    required this.customerId,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  String _selectedSize = 'M';

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: AppBar(
        backgroundColor: kPrimaryDarkColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Item Details',
          style: TextStyle(color: kTextPrimaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: kTextPrimaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Garment Image
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                item.imageAsset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),

            // Item Name & Price
            Text(
              item.name,
              style: const TextStyle(
                color: kTextPrimaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.formattedPrice,
              style: const TextStyle(
                color: kAccentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              item.description,
              style: TextStyle(color: kTextSecondaryColor, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Size Selector
            const Text(
              'Sizes:',
              style: TextStyle(
                color: kTextPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: item.sizes.map((size) {
                final isSelected = size == _selectedSize;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSize = size),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? kAccentColor : kCardBgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? kAccentColor : Colors.grey.shade600,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.white : kTextSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TryOnScreen(
                      item: item,
                      selectedSize: _selectedSize,
                      customerId: widget.customerId,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
                child: const Text(
                  'Try-on',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  final success = await ApiService.instance.addToWishlist(
                    widget.customerId, item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                        ? '${item.name} added to wishlist!'
                        : 'Already in wishlist or failed'),
                      backgroundColor: success ? kAccentColor : Colors.redAccent,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kAccentColor),
                  foregroundColor: kAccentColor,
                ),
                child: const Text(
                  'Add to Wishlist',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kCardBgColor,
        selectedItemColor: kAccentColor,
        unselectedItemColor: kTextSecondaryColor,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
