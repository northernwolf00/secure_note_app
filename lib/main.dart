import 'package:flutter/material.dart';
import 'package:secure_note_app/core/utils/app_colors.dart';
import 'package:secure_note_app/core/utils/route_generator.dart';
import 'package:secure_note_app/data/local/lock_screen.dart';
import 'package:secure_note_app/firebase_options.dart';
import 'package:secure_note_app/presentation/screens/auth/sign_in_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secure_note_app/presentation/screens/home/home_screen.dart';
import 'package:secure_note_app/services/auth_service.dart'; // <- Import HomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(), 
    );
  }
}



class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _hasLocalLock = false;
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocalLock();
  }

  Future<void> _checkLocalLock() async {
    final pin = await AuthService().getPin();
    final password = await AuthService().getPassword();
    setState(() {
      _hasLocalLock = pin != null || password != null;
      _authChecked = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      setState(() {
        _unlocked = false;
      });
    }
  }

  void _unlock() {
    setState(() {
      _unlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_authChecked
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              } else if (!snapshot.hasData) {
                return const SignInScreen();
              } else if (_hasLocalLock && !_unlocked) {
                return LockScreen(onUnlock: _unlock);
              } else {
                return const HomeScreen();
              }
            },
          );
  }
}






