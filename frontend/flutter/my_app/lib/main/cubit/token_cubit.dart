import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:equatable/equatable.dart';

part 'token_state.dart';

class TokenCubit extends Cubit<TokenState> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  TokenCubit() : super(TokenState.initial()) {
    _loadTokenCount();
  }

  Future<void> _loadTokenCount() async {
    try {
      String? tokenCountString = await _storage.read(key: 'tokenCount');
      if (tokenCountString != null) {
        int tokenCount = int.parse(tokenCountString);
        developer.log('Loaded token count: $tokenCount', name: 'TokenCubit');
        emit(state.copyWith(tokenCount: tokenCount));
      }
    } catch (e) {
      developer.log('Error loading token count: $e',
          name: 'TokenCubit', error: e);
    }
  }

  Future<void> addTokens(int amount) async {
    try {
      var currentTokenCount = state.tokenCount;

      if (currentTokenCount + amount <= 30) {
        await _storage.write(key: 'tokenUpdated', value: 'true');
        currentTokenCount += amount;
        developer.log('$currentTokenCount', name: 'TokenCubit');

        await _storage.write(
            key: 'tokenCount', value: currentTokenCount.toString());
        developer.log('Token count increased: $currentTokenCount (+$amount)',
            name: 'TokenCubit');

        emit(state.copyWith(
            tokenCount: currentTokenCount,
            tokenLimitReached: false,
            tokenUpdated: true));
      } else {
        developer.log('Token limit reached', name: 'TokenCubit');
        emit(state.copyWith(
            tokenLimitReached: true,
            timstamp: DateTime.now().toIso8601String()));
      }
    } catch (e) {
      developer.log('Error adding tokens: $e', name: 'TokenCubit', error: e);
    }
  }

  Future<void> useTokens(int amount) async {
    try {
      var currentTokenCount = state.tokenCount;

      if (currentTokenCount >= amount) {
        await _storage.write(key: 'tokenUpdated', value: 'true');
        developer.log('$currentTokenCount');
        currentTokenCount -= amount;
        developer.log('$currentTokenCount');

        await _storage.write(
            key: 'tokenCount', value: currentTokenCount.toString());
        developer.log('Token count decreased: $currentTokenCount (-$amount)',
            name: 'TokenCubit');

        emit(state.copyWith(
            tokenCount: currentTokenCount, tokenLimitReached: false));
      } else {
        developer.log('Not enough tokens', name: 'TokenCubit');
      }
    } catch (e) {
      developer.log('Error using tokens: $e', name: 'TokenCubit', error: e);
    }
  }
}
