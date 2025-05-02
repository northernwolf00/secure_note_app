import 'package:flutter/material.dart';
import 'package:secure_note_app/core/utils/app_colors.dart';
import 'package:secure_note_app/services/auth_service.dart';

class PinSettingsScreen extends StatefulWidget {
  const PinSettingsScreen({super.key});

  @override
  State<PinSettingsScreen> createState() => _PinSettingsScreenState();
}

class _PinSettingsScreenState extends State<PinSettingsScreen> {
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  String? _savedPin;

  @override
  void initState() {
    super.initState();
    _loadSavedPin();
  }

  Future<void> _loadSavedPin() async {
    final pin = await AuthService().getPin();
    setState(() {
      _savedPin = pin;
    });
  }

  Future<void> _changePin() async {
      await AuthService().clearAuthData();
    final old = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();

    if (_savedPin?.isNotEmpty == true && old != _savedPin) {
      _showMessage('Old PIN is incorrect');
      return;
    }

    if (newPin.isEmpty) {
      _showMessage('New PIN cannot be empty');
      return;
    }

    await AuthService().savePin(newPin);
    _showMessage('PIN changed successfully');
    _oldPinController.clear();
    _newPinController.clear();
    _loadSavedPin();
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
        title: const Text('Change PIN'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_savedPin != null && _savedPin!.isNotEmpty)
              TextField(
                controller: _oldPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Old PIN'),
              ),
            if (_savedPin != null && _savedPin!.isNotEmpty)
              const SizedBox(height: 16),
            TextField(
              controller: _newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('New PIN'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _changePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save PIN',
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
