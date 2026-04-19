import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clothing_item.dart';

/// ApiService — Handles all HTTP requests to the Node.js backend connected to PostgreSQL database.
class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  //PC's IP address
  static const String _baseUrl = 'http://192.168.8.184:3000/api';

  //Get All Clothing Items
  Future<List<ClothingItem>> fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['data'];
        return items.map((item) => ClothingItem(
          id: item['item_id'],
          name: item['name'],
          price: double.parse(item['price'].toString()),
          category: item['category_name'],
          description: item['description'] ?? '',
          sizes: item['sizes'].toString().split(','),
          imageAsset: item['image_url'],
          arOverlayAsset: item['ar_overlay_url'],
        )).toList();
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      // Return mock data if server not available
      print('API Error: $e — using mock data');
      return mockClothingCatalog;
    }
  }

  //Get Items by Category
  Future<List<ClothingItem>> fetchItemsByCategory(
      String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/items/category/$category'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['data'];
        return items.map((item) => ClothingItem(
          id: item['item_id'],
          name: item['name'],
          price: double.parse(item['price'].toString()),
          category: item['category_name'],
          description: item['description'] ?? '',
          sizes: item['sizes'].toString().split(','),
          imageAsset: item['image_url'],
          arOverlayAsset: item['ar_overlay_url'],
        )).toList();
      }
      return [];
    } catch (e) {
      print('API Error: $e');
      return [];
    }
  }

  //Admin Login
  Future<Map<String, dynamic>?> adminLogin(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  //Add Item (Admin)
  Future<bool> addItem({
    required String name,
    required double price,
    required String description,
    required String sizes,
    required String imageUrl,
    required int categoryId,
    required int ownerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'price': price,
          'description': description,
          'sizes': sizes,
          'image_url': imageUrl,
          'ar_overlay_url': imageUrl,
          'category_id': categoryId,
          'owner_id': ownerId,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Add item error: $e');
      return false;
    }
  }

  //Delete Item (Admin)
  Future<bool> deleteItem(int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/items/$itemId'),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  //Add to Wishlist
  Future<bool> addToWishlist(
      int customerId, int itemId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/wishlist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_id': customerId,
          'item_id': itemId,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('Wishlist error: $e');
      return false;
    }
  }

  //Customer Login
  Future<Map<String, dynamic>?> customerLogin(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Customer login error: $e');
      return null;
    }
  }

  //Customer Register
  Future<Map<String, dynamic>?> customerRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customer/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Customer register error: $e');
      return null;
    }
  }
}