import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/token_storage.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isAdmin;
  final String? userId;
  final String? email;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.userId,
    this.email,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isAdmin,
    String? userId,
    String? email,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final saved = await TokenStorage.load();
    if (saved != null) {
      state = AuthState(
        isAuthenticated: true,
        isAdmin: saved.isAdmin,
        userId: saved.userId,
        email: saved.email,
        token: saved.token,
      );
    }
  }

  void _applyResponse(AuthResponse response) {
    state = AuthState(
      isAuthenticated: true,
      isAdmin: response.isAdmin,
      userId: response.userId,
      email: response.email,
      token: response.token,
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await ApiClient.post(
        ApiConstants.login,
        LoginRequest(email: email, password: password).toJson(),
      );
      final response = AuthResponse.fromJson(json);
      await TokenStorage.save(
        token: response.token,
        userId: response.userId,
        email: response.email,
        isAdmin: response.isAdmin,
      );
      _applyResponse(response);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error. Try again.');
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await ApiClient.post(
        ApiConstants.register,
        RegisterRequest(email: email, password: password).toJson(),
      );
      final response = AuthResponse.fromJson(json);
      await TokenStorage.save(
        token: response.token,
        userId: response.userId,
        email: response.email,
        isAdmin: response.isAdmin,
      );
      _applyResponse(response);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error. Try again.');
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);
