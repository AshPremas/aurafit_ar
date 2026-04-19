import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/clothing_item.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  ADMIN LOGIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════

/// AdminLoginScreen — Secure login portal for shop owners.
/// Validates credentials against the PostgreSQL backend (mocked in PoC).
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

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulated auth
    setState(() => _isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
    );
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
                  style: TextStyle(
                      color: kTextPrimaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              const Text('Admin Login',
                  style: TextStyle(
                      color: kTextPrimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              _InputField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter email'),
              const SizedBox(height: 16),
              _InputField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter password',
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: kTextSecondaryColor),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?',
                      style: TextStyle(color: kAccentColor)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ADMIN DASHBOARD SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: AppBar(
        backgroundColor: kPrimaryDarkColor,
        elevation: 0,
        title: const Text('Admin Dashboard',
            style: TextStyle(color: kTextPrimaryColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome, Admin!',
                style: TextStyle(
                    color: kTextPrimaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(title: 'Total Revenue', value: 'LKR XXX.xx'),
                const SizedBox(width: 12),
                _StatCard(title: 'Total Orders', value: '150'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddItemScreen())),
                child: const Text('+ Add New Item'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CatalogScreen())),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(color: kTextSecondaryColor, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: kTextPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CATALOG SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: AppBar(
        backgroundColor: kPrimaryDarkColor,
        title: const Text('Manage Catalog',
            style: TextStyle(color: kTextPrimaryColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.close, color: kTextPrimaryColor),
              onPressed: () => Navigator.pop(context))
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockClothingCatalog.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _CatalogItemRow(item: mockClothingCatalog[i]),
      ),
    );
  }
}

class _CatalogItemRow extends StatelessWidget {
  final ClothingItem item;
  const _CatalogItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: kCardBgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.white10, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.checkroom, color: kAccentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: const TextStyle(
                      color: kTextPrimaryColor, fontWeight: FontWeight.bold)),
              Text(item.formattedPrice,
                  style: const TextStyle(color: kAccentColor, fontSize: 13)),
            ]),
          ),
          TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 16, color: kAccentColor),
              label: const Text('Edit', style: TextStyle(color: kAccentColor))),
          TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
              label: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ADD ITEM SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['Tops', 'Bottoms', 'Dresses', 'Sarees'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: AppBar(
        backgroundColor: kPrimaryDarkColor,
        title: const Text('Upload New Item',
            style: TextStyle(color: kTextPrimaryColor, fontWeight: FontWeight.bold)),
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
            // Image upload area
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: kCardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade600, width: 1.5)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.cloud_upload_outlined,
                    color: kAccentColor, size: 40),
                const SizedBox(height: 8),
                Text('Upload picture to display\nTap to Upload\nor drag & drop',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextSecondaryColor, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 16),
            _InputField(controller: _nameController, label: 'Name', hint: 'Enter Name'),
            const SizedBox(height: 12),
            const Text('Category:',
                style: TextStyle(color: kTextPrimaryColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              dropdownColor: kCardBgColor,
              style: const TextStyle(color: kTextPrimaryColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: kCardBgColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
              hint: Text('Select', style: TextStyle(color: kTextSecondaryColor)),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 12),
            _InputField(
                controller: _priceController,
                label: 'Price',
                hint: 'Enter Price LKR',
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _InputField(
                controller: _descController,
                label: 'Description',
                hint: 'Add A description',
                maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Item saved successfully'),
                    backgroundColor: kAccentColor,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Input Field Widget ────────────────────────────────────────────────
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
            style: const TextStyle(
                color: kTextPrimaryColor, fontWeight: FontWeight.w600)),
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
