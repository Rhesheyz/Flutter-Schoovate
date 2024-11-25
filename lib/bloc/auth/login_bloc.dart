import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());

      try {
        final response = await http.post(
          Uri.parse('https://schoovate.apps-project.com/api/login'),
          body: {
            'email': event.email,
            'password': event.password,
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final String token = data['access_token'];
          final String role = data['data_user']['role'];
          final int isRoot = data['data_user']['is_root'];

          // Simpan token, role, dan is_root di SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('role', role);
          await prefs.setInt('is_root', isRoot);

          if (isRoot == 1 && role == 'admin') {
            emit(LoginSuccessRoot());
          } else if (role == 'admin') {
            emit(LoginSuccess());
          } else if (role == 'user') {
            emit(LoginUserSuccess());
          }
        } else {
          emit(LoginFailure(error: 'Login gagal. Periksa email dan password.'));
        }
      } catch (error) {
        emit(LoginFailure(error: 'Terjadi kesalahan, coba lagi.'));
      }
    });

    // Add the checkToken method here to call it when the bloc is created
  }

  Future<void> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final isRoot = prefs.getInt('is_root');

    if (token != null && role != null) {
      if (isRoot == 1 && role == 'admin') {
        emit(LoginSuccessRoot());
      } else if (role == 'admin') {
        emit(LoginSuccess());
      } else if (role == 'user') {
        emit(LoginUserSuccess());
      }
    }
  }
}
