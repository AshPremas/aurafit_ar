import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';
import '../../services/api_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    final result = await ApiService.instance.adminLogin(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => AdminDashboardScreen(
          adminName: result['username'] ?? 'Admin',
          ownerId: result['owner_id'] ?? 1,
        )));
    } else {
      setState(() => _errorMessage = 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.checkroom_rounded, size: 70, color: kAccentColor),
              const SizedBox(height: 8),
              const Text('AuraFit AR',
                  style: TextStyle(color: kTextPrimaryColor,
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              const Text('Admin Login',
                  style: TextStyle(color: kTextPrimaryColor,
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              _InputField(controller: _emailController,
                  label: 'Email', hint: 'admin@aurafit.com'),
              const SizedBox(height: 16),
              _InputField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter password',
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off : Icons.visibility,
                      color: kTextSecondaryColor),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


///  Admin Dashboard Screen
class AdminDashboardScreen extends StatefulWidget {
  final String adminName;
  final int ownerId;

  const AdminDashboardScreen({
    super.key,
    required this.adminName,
    required this.ownerId,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final items = await ApiService.instance.fetchItems();
    setState(() => _itemCount = items.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: AppBar(
        backgroundColor: kPrimaryDarkColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard',
            style: TextStyle(color: kTextPrimaryColor,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kTextPrimaryColor),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${widget.adminName}!',
                style: const TextStyle(color: kTextPrimaryColor,
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(title: 'Total Items', value: '$_itemCount'),
                const SizedBox(width: 12),
                _StatCard(title: 'Categories', value: '4'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AddItemScreen(ownerId: widget.ownerId)));
                  _loadStats();
                },
                child: const Text('+ Add New Item'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => CatalogScreen(ownerId: widget.ownerId)));
                  _loadStats();
                },
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kAccentColor),
                    foregroundColor: kAccentColor),
                child: const Text('Manage Catalog'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: kCardBgColor, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(color: kTextSecondaryColor, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(color: kTextPrimaryColor,
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}


//  CATALOG SCREEN
class CatalogScreen extends StatefulWidget {
  final int ownerId;
  const CatalogScreen({super.key, required this.ownerId});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<ClothingItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await ApiService.instance.fetchItems();
    setState(() { _items = items; _isLoading = false; });
  }

  Future<void> _deleteItem(ClothingItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCardBgColor,
        title: const Text('Delete Item',
            style: TextStyle(color: kTextPrimaryColor)),
        content: Text('Delete "${item.name}"?',
            style: TextStyle(color: kTextSecondaryColor)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.instance.deleteItem(item.id);
      if (success) {
        _loadItems();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} deleted'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: AppBar(
        backgroundColor: kPrimaryDarkColor,
        title: const Text('Manage Catalog',
            style: TextStyle(color: kTextPrimaryColor,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.close, color: kTextPrimaryColor),
              onPressed: () => Navigator.pop(context))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : _items.isEmpty
              ? const Center(child: Text('No items yet',
                  style: TextStyle(color: kTextSecondaryColor)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _CatalogItemRow(
                    item: _items[i],
                    onDelete: () => _deleteItem(_items[i]),
                  ),
                ),
    );
  }
}

class _CatalogItemRow extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onDelete;
  const _CatalogItemRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: kCardBgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(item.imageAsset,
                width: 60, height: 60, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60, height: 60, color: Colors.white10,
                  child: const Icon(Icons.checkroom, color: kAccentColor),
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(color: kTextPrimaryColor,
                          fontWeight: FontWeight.bold)),
                  Text(item.formattedPrice,
                      style: const TextStyle(color: kAccentColor,
                          fontSize: 13)),
                  Text(item.category,
                      style: TextStyle(color: kTextSecondaryColor,
                          fontSize: 11)),
                ]),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}


/// Add Item Screen
class AddItemScreen extends StatefulWidget {
  final int ownerId;
  const AddItemScreen({super.key, required this.ownerId});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  final Map<String, int> _categoryIds = {
    'Tops': 1,
    'Bottoms': 2,
    'Dresses': 3,
    'Sarees': 4,
  };

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService.instance.addItem(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      description: _descController.text.trim(),
      sizes: 'S,M,L,XL',
      imageUrl: 'assets/images/blackshirt.png', // default image
      categoryId: _categoryIds[_selectedCategory!] ?? 1,
      ownerId: widget.ownerId,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Item added successfully!'),
        backgroundColor: kAccentColor,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add item. Check server connection.'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: AppBar(
        backgroundColor: kPrimaryDarkColor,
        title: const Text('Add New Item',
            style: TextStyle(color: kTextPrimaryColor,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.close, color: kTextPrimaryColor),
              onPressed: () => Navigator.pop(context))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: kCardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade600, width: 1.5)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined,
                        color: kAccentColor, size: 40),
                    const SizedBox(height: 8),
                    Text('Upload clothing image',
                        style: TextStyle(color: kTextSecondaryColor,
                            fontSize: 13)),
                  ]),
            ),
            const SizedBox(height: 16),
            _InputField(controller: _nameController,
                label: 'Item Name *', hint: 'e.g. Blue Dress'),
            const SizedBox(height: 12),
            const Text('Category *',
                style: TextStyle(color: kTextPrimaryColor,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              dropdownColor: kCardBgColor,
              style: const TextStyle(color: kTextPrimaryColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: kCardBgColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
              hint: Text('Select category',
                  style: TextStyle(color: kTextSecondaryColor)),
              items: _categoryIds.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 12),
            _InputField(
                controller: _priceController,
                label: 'Price (LKR) *',
                hint: 'e.g. 3500',
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _InputField(
                controller: _descController,
                label: 'Description',
                hint: 'Add a description',
                maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveItem,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save to Database',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shared Input Field
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: kTextPrimaryColor,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: kTextPrimaryColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextSecondaryColor),
            filled: true,
            fillColor: kCardBgColor,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}