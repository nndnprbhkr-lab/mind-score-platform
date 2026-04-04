import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/token_storage.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isAdmin;
  final bool isGuest;
  final String? userId;
  final String? name;
  final String? email;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.isGuest = false,
    this.userId,
    this.name,
    this.email,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isAdmin,
    bool? isGuest,
    String? userId,
    String? name,
    String? email,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
      isGuest: isGuest ?? this.isGuest,
      userId: userId ?? this.userId,
      name: name ?? this.name,
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
        isGuest: saved.isGuest,
        userId: saved.userId,
        name: saved.name,
        email: saved.email,
        token: saved.token,
      );
    }
  }

  void _applyResponse(AuthResponse response) {
    state = AuthState(
      isAuthenticated: true,
      isAdmin: response.isAdmin,
      isGuest: response.isGuest,
      userId: response.userId,
      name: response.name,
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
        name: response.name,
        email: response.email,
        isAdmin: response.isAdmin,
        isGuest: response.isGuest,
      );
      _applyResponse(response);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error. Try again.');
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await ApiClient.post(
        ApiConstants.register,
        RegisterRequest(name: name, email: email, password: password).toJson(),
      );
      final response = AuthResponse.fromJson(json);
      await TokenStorage.save(
        token: response.token,
        userId: response.userId,
        name: response.name,
        email: response.email,
        isAdmin: response.isAdmin,
        isGuest: response.isGuest,
      );
      _applyResponse(response);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error. Try again.');
    }
  }

  Future<void> guestLogin(String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await ApiClient.post(
        ApiConstants.guestLogin,
        GuestLoginRequest(name: name).toJson(),
      );
      final response = AuthResponse.fromJson(json);
      await TokenStorage.save(
        token: response.token,
        userId: response.userId,
        name: response.name,
        email: response.email,
        isAdmin: response.isAdmin,
        isGuest: response.isGuest,
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
