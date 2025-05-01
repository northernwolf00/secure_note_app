import 'package:flutter/material.dart';
import 'package:secure_note_app/main.dart';
import 'package:secure_note_app/presentation/screens/auth/sign_in_screen.dart';
import 'package:secure_note_app/presentation/screens/auth/sign_up_screen.dart';
import 'package:secure_note_app/presentation/screens/home/home_screen.dart';
import 'package:secure_note_app/presentation/widgets/not_found_screen.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
 

    switch (settings.name) {
       case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/sign-up':
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => SignInScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => NotFoundScreen(),
        );
    }
  }
}
