import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/data/models/user_model.dart';
import 'package:test_app/data/repositories/auth_repository.dart';
import 'package:test_app/data/shared_prefs_service.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SharedPrefsService _prefs = SharedPrefsService.instance;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<LoginUser>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.login(
        email: event.email,
        password: event.password,
      ); //тут бы я принимал данные с запроса и дальше бы с ними работал(отображение, сохранение и тд)
      final UserModel user = UserModel(
        email: event.email,
        name: '',
        surname: '',
      );
      await _prefs.saveUser(
        user,
      ); //это тот самый локальный сервис для хранения данных
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(const AuthFailure('Ошибка авторизации'));
    }
  }
}
