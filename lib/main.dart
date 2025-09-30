import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/data/models/user_model.dart';
import 'package:test_app/data/repositories/auth_repository.dart';
import 'package:test_app/data/repositories/calendar_repository.dart';
import 'package:test_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:test_app/presentation/bloc/calendar/calendar_bloc.dart';
import 'package:test_app/presentation/screens/auth_screen.dart';
import 'package:test_app/presentation/screens/calendar_screen.dart';

UserModel? user;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        inputDecorationTheme: const InputDecorationTheme(
          hoverColor: Colors.grey,
          focusColor: Colors.grey,
          labelStyle: TextStyle(color: Colors.grey),
          floatingLabelStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          prefixIconColor: Colors.grey,
          suffixIconColor: Colors.grey,
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<AuthBloc>(
              create: (BuildContext context) =>
                  AuthBloc(authRepository: AuthRepository()),
            ),
            BlocProvider<CalendarBloc>(
              create: (BuildContext context) =>
                  CalendarBloc(calendarRepository: CalendarRepository()),
            ),
          ],
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthScreen(),
      routes: {
        "/login": (context) => const AuthScreen(),
        "/calendar": (context) => const CalendarScreen(),
      },
    );
  }
}
