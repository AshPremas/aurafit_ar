import 'package:flutter/material.dart';
import '../../main.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int customerId;
  final String customerName;
  final String customerEmail;

  const ProfileScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDarkColor,
      appBar: AppBar(
        backgroundColor: kPrimaryDarkColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profile',
            style: TextStyle(color: kTextPrimaryColor,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: kAccentColor,
              child: Text(
                customerName.isNotEmpty
                    ? customerName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 40,
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(customerName,
                style: const TextStyle(color: kTextPrimaryColor,
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(customerEmail,
                style: TextStyle(color: kTextSecondaryColor, fontSize: 14)),
            const SizedBox(height: 32),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: kCardBgColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.person_outline,
                      label: 'Name', value: customerName),
                  const Divider(color: Colors.white12),
                  _InfoRow(icon: Icons.email_outlined,
                      label: 'Email', value: customerEmail),
                  const Divider(color: Colors.white12),
                  _InfoRow(icon: Icons.badge_outlined,
                      label: 'Customer ID', value: '#$customerId'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: kCardBgColor,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _MenuRow(
                    icon: Icons.favorite_outline,
                    label: 'My Wishlist',
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _MenuRow(
                    icon: Icons.history,
                    label: 'Try-on History',
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _MenuRow(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                ),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('Logout',
                    style: TextStyle(color: Colors.redAccent,
                        fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: kAccentColor, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(color: kTextSecondaryColor, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(color: kTextPrimaryColor,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: kAccentColor),
      title: Text(label,
          style: const TextStyle(color: kTextPrimaryColor)),
      trailing: const Icon(Icons.chevron_right,
          color: Colors.white24),
    );
  }
}