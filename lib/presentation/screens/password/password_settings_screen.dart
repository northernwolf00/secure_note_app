import 'package:flutter/material.dart';
import 'package:secure_note_app/core/utils/app_colors.dart';
import 'package:secure_note_app/services/auth_service.dart';

class PasswordSettingsScreen extends StatefulWidget {
  const PasswordSettingsScreen({super.key});

  @override
  State<PasswordSettingsScreen> createState() => _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState extends State<PasswordSettingsScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String? _savedPassword;

  @override
  void initState() {
    super.initState();
    _loadSavedPassword();
  }

  Future<void> _loadSavedPassword() async {
    final password = await AuthService().getPassword();
    setState(() {
      _savedPassword = password;
    });
  }

  Future<void> _changePassword() async {
    await AuthService().clearAuthData();
    final old = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (_savedPassword?.isNotEmpty == true && old != _savedPassword) {
      _showMessage('Old password is incorrect');
      return;
    }

    if (newPassword.isEmpty) {
      _showMessage('New password cannot be empty');
      return;
    }

    

    await AuthService().savePassword(newPassword);
    _showMessage('Password changed successfully');
    _oldPasswordController.clear();
    _newPasswordController.clear();
    
    _loadSavedPassword();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_savedPassword != null && _savedPassword!.isNotEmpty)
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: _inputDecoration('Old Password'),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: _inputDecoration('New Password'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                ),
                child: const Text(
                  'Save Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
