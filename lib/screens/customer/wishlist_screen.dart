import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import '../../services/wishlist_service.dart';
import 'try_on_screen.dart';

/// WishlistScreen — Displays the customer's saved clothing items.
/// Supports "Try Again" (re-launch AR) and "Delete" actions per item.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<ClothingItem> get _items => WishlistService.instance.items;

  void _removeItem(int itemId) {
    setState(() => WishlistService.instance.removeItem(itemId));
  }

  @override
  Widget build(BuildContext context) {
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
          'My Wishlist',
          style: TextStyle(color: kTextPrimaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: kTextPrimaryColor),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Text(
                'Your wishlist is empty',
                style: TextStyle(color: kTextSecondaryColor, fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _WishlistCard(
                item: _items[i],
                onRemove: () => _removeItem(_items[i].id),
              ),
            ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onRemove;
  const _WishlistCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.checkroom, color: kAccentColor, size: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        color: kTextPrimaryColor, fontWeight: FontWeight.bold)),
                Text(item.formattedPrice,
                    style: const TextStyle(color: kAccentColor, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ActionBtn(
                      label: 'Try Again',
                      icon: Icons.refresh,
                      color: kAccentColor,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TryOnScreen(item: item, selectedSize: 'M'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      label: 'Delete',
                      icon: Icons.delete,
                      color: Colors.redAccent,
                      onTap: onRemove,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
