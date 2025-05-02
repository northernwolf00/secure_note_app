import 'package:flutter/material.dart';
import 'package:secure_note_app/core/utils/app_colors.dart';
import 'package:secure_note_app/services/auth_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;

  const LockScreen({super.key, required this.onUnlock});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _controller = TextEditingController();
  final AuthService _authService = AuthService();
  String? _pin;
  String? _password;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final pin = await _authService.getPin();
    final password = await _authService.getPassword();
    setState(() {
      _pin = pin;
      _password = password;
    });
  }

  void _verify() {
    final input = _controller.text.trim();
    if ((_pin != null && input == _pin) || (_password != null && input == _password)) {
      widget.onUnlock();
    } else {
      setState(() {
        _error = 'Incorrect PIN or Password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _pin != null
        ? 'Enter your PIN'
        : _password != null
            ? 'Enter your Password'
            : 'No lock set';

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 64, color: AppColors.primary),
                const SizedBox(height: 20),
                Text(
                  prompt,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  keyboardType: _pin != null ? TextInputType.number : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: _pin != null ? 'PIN' : 'Password',
                    errorText: _error,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _verify,
                    child: const Text('Unlock', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
