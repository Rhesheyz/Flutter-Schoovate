import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_123/screens/user_screen.dart';
import 'bloc/auth/logout_bloc.dart'; // Import LogoutBloc
import 'bloc/auth/login_bloc.dart'; // Import LoginBloc
import 'screens/welcome_screen.dart'; // Import WelcomeScreen
import 'screens/login_screen.dart'; // Import LoginScreen
import 'screens/agenda/agenda.dart'; // Import AgendaScreen

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LogoutBloc(), // Inisialisasi LogoutBloc
        ),
        BlocProvider(
          create: (context) => LoginBloc(), // Inisialisasi LoginBloc
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schoovate',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Gunakan MaterialColor bawaan
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/User': (context) => const UserScreen(),
        '/agenda': (context) => const AgendaScreen(),
      },
    );
  }
}
