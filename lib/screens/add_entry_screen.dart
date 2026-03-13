import 'package:flutter/material.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  // ── Controllers — like input buffers for each text field ──
  final _siteController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    // always dispose controllers to free memory
    _siteController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    // trim() removes extra spaces before/after
    final site = _siteController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // validate — all fields must be filled
    if (site.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // return data back to MainScreen
    Navigator.pop(context, {
      'siteName': site,
      'username': username,
      'password': password,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Add Password',
          style: TextStyle(
            color: Color(0xFFE2E8F0),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE2E8F0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Site name field ──
            _buildField(
              controller: _siteController,
              label: 'Site Name',
              hint: 'e.g. Google, Netflix',
              icon: Icons.language,
            ),

            const SizedBox(height: 16),

            // ── Username field ──
            _buildField(
              controller: _usernameController,
              label: 'Username',
              hint: 'e.g. john@email.com',
              icon: Icons.person,
            ),

            const SizedBox(height: 16),

            // ── Password field ──
            _buildField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter password',
              icon: Icons.lock,
              isPassword: true,
            ),

            const SizedBox(height: 32),

            // ── Save button ──
            SizedBox(
              width: double.infinity, // full width
              height: 52,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !_passwordVisible, // hide password chars
          style: const TextStyle(color: Color(0xFFE2E8F0)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF3D3D5C)),
            prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF13131F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E1E2E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E1E2E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
      ],
    );
  }
}
