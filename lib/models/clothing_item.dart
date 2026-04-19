/// Represents a single clothing item in the catalog.
/// Used across HomeScreen, ItemDetailsScreen, WishlistScreen, and TryOnScreen.
class ClothingItem {
  final int id;
  final String name;
  final double price;
  final String category;
  final String description;
  final List<String> sizes;
  final String imageAsset;
  final String arOverlayAsset; // PNG with transparent bg used for AR overlay
  final int? wishlistId;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.sizes,
    required this.imageAsset,
    required this.arOverlayAsset,
    this.wishlistId,
  });

  /// Formatted price string in Sri Lankan Rupees
  String get formattedPrice => 'LKR ${price.toStringAsFixed(2)}';
}

// Mock Catalog Data (In production this data is fetched from the PostgreSQL backend.)

final List<ClothingItem> mockClothingCatalog = [
  const ClothingItem(
    id: 1,
    name: 'Green Frock',
    price: 3500.00,
    category: 'Dresses',
    description:
        'Elegant and lightweight floral frock designed for everyday comfort. '
        'Made with breathable fabric, it features a flattering fit and stylish '
        'detailing, perfect for casual outings or semi-formal occasions.',
    sizes: ['S', 'M', 'L', 'XL'],
    imageAsset: 'assets/images/frock.png',
    arOverlayAsset: 'assets/images/frock.png',
  ),
  const ClothingItem(
    id: 2,
    name: 'Red Saree',
    price: 4500.00,
    category: 'Sarees',
    description:
        'Traditional handwoven red saree with golden border embroidery. '
        'Suitable for festive occasions and formal events.',
    sizes: ['S', 'M', 'L', 'XL'],
    imageAsset: 'assets/images/redsaree.png',
    arOverlayAsset: 'assets/images/redsaree.png',
  ),
  const ClothingItem(
    id: 3,
    name: 'Black T-Shirt',
    price: 1500.00,
    category: 'Tops',
    description:
        'Classic slim-fit black T-shirt made from 100% cotton. '
        'Versatile and comfortable for daily wear.',
    sizes: ['S', 'M', 'L', 'XL'],
    imageAsset: 'assets/images/blackshirt.png',
    arOverlayAsset: 'assets/images/blackshirt.png',
  ),
  const ClothingItem(
    id: 4,
    name: 'Plain Pant',
    price: 2500.00,
    category: 'Bottoms',
    description:
        'Comfortable plain trousers with a modern slim cut. '
        'Ideal for both casual and office settings.',
    sizes: ['S', 'M', 'L', 'XL'],
    imageAsset: 'assets/images/pant.png',
    arOverlayAsset: 'assets/images/pant.png',
  ),
];