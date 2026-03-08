import '../models/clothing_item.dart';

/// WishlistService — Singleton in-memory store for wishlisted items.
/// In production, wishlist entries are persisted to the PostgreSQL database.
class WishlistService {
  WishlistService._internal();
  static final WishlistService instance = WishlistService._internal();

  final List<ClothingItem> _items = [];

  List<ClothingItem> get items => List.unmodifiable(_items);

  void addItem(ClothingItem item) {
    if (!_items.any((i) => i.id == item.id)) {
      _items.add(item);
    }
  }

  void removeItem(int itemId) {
    _items.removeWhere((i) => i.id == itemId);
  }

  bool contains(int itemId) => _items.any((i) => i.id == itemId);
}
