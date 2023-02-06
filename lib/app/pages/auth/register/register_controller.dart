import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dw9_delivery_app/app/repositories/auth/auth_repository.dart';

import 'register_state.dart';

class RegisterController extends Cubit<RegisterState> {
  RegisterController(this._authRepository)
      : super(const RegisterState.initial());

  final AuthRepository _authRepository;

  Future<void> register(String name, String email, String password) async {
    try {
      emit(state.copyWith(status: RegisterStatus.register));

      await _authRepository.register(name, email, password);

      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e, s) {
      log('Erro ao registrar usuário', error: e, stackTrace: s);
      emit(state.copyWith(status: RegisterStatus.error));
    }
  }
}
