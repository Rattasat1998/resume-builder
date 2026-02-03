import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../../features/subscription/domain/repositories/subscription_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for handling authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SubscriptionRepository _subscriptionRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required SubscriptionRepository subscriptionRepository,
  }) : _authRepository = authRepository,
       _subscriptionRepository = subscriptionRepository,
       super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthErrorCleared>(_onErrorCleared);

    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        // Sync RevenueCat ID
        _subscriptionRepository.logIn(user.id);
        // ignore: invalid_use_of_visible_for_testing_member
        emit(AuthState.authenticated(user));
      } else if (state.status != AuthStatus.initial) {
        // Sync RevenueCat Logout
        _subscriptionRepository.logOut();
        // ignore: invalid_use_of_visible_for_testing_member
        emit(const AuthState.unauthenticated());
      }
    });
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      await _subscriptionRepository.logIn(user.id);
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signIn(
      email: event.email,
      password: event.password,
    );

    await result.fold(
      onSuccess: (user) async {
        await _subscriptionRepository.logIn(user.id);
        emit(AuthState.authenticated(user));
      },
      onFailure: (failure) async => emit(state.withError(failure.message)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signUp(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
    );

    await result.fold(
      onSuccess: (user) async {
        await _subscriptionRepository.logIn(user.id);
        emit(AuthState.authenticated(user));
      },
      onFailure: (failure) async => emit(state.withError(failure.message)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signOut();

    await result.fold(
      onSuccess: (_) async {
        await _subscriptionRepository.logOut();
        emit(const AuthState.unauthenticated());
      },
      onFailure: (failure) async => emit(state.withError(failure.message)),
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.sendPasswordResetEmail(event.email);

    result.fold(
      onSuccess: (_) =>
          emit(const AuthState.unauthenticated().withPasswordResetSent()),
      onFailure: (failure) => emit(state.withError(failure.message)),
    );
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;

    final result = await _authRepository.updateProfile(
      fullName: event.fullName,
      avatarUrl: event.avatarUrl,
    );

    result.fold(
      onSuccess: (user) => emit(AuthState.authenticated(user)),
      onFailure: (failure) => emit(state.withError(failure.message)),
    );
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.clearError());
  }

  Future<void> _onSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signInWithGoogle();

    await result.fold(
      onSuccess: (user) async {
        await _subscriptionRepository.logIn(user.id);
        emit(AuthState.authenticated(user));
      },
      onFailure: (failure) async {
        print('Google sign-in failed: ${failure.message}');
        emit(state.withError(failure.message));
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
