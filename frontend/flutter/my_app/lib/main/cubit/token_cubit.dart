import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:date_spark_app/helper_functions.dart';
import 'package:date_spark_app/services/api/index.dart';
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
        // Optionally emit a state for insufficient tokens if needed
      }
    } catch (e) {
      developer.log('Error using tokens: $e', name: 'TokenCubit', error: e);
    }
  }

  Future<void> updateBackendTokenCount() async {
    final tokenUpdated = await _storage.read(key: 'tokenUpdated') ?? 'false';
    developer.log('Token updated status: $tokenUpdated', name: 'TokenCubit');
    if (tokenUpdated == 'true') {
      final currentTokenCount = state.tokenCount;
      developer.log('Updating backend with token count: $currentTokenCount',
          name: 'TokenCubit');

      final accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        developer.log(
            'Access token not found or is empty. Cannot update token count.',
            name: 'TokenCubit');
        return;
      }

      final headers = {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json"
      };
      final body = {'tokenCount': currentTokenCount};

      try {
        final request = await ApiService.instance
            .post('update-token', headers: headers, body: body);
        developer.log(
            'Response: ${request.data}, Status Code: ${request.statusCode}');
        if (request.statusCode == 200) {
          await _storage.write(key: 'tokenUpdated', value: 'false');
          developer.log('Backend token count updated successfully',
              name: 'TokenCubit');
          emit(state.copyWith(tokenUpdated: false));
        } else {
          developer.log(
              'Failed to update backend token count. Status Code: ${request.statusCode}',
              name: 'TokenCubit');
        }
      } catch (e) {
        developer.log('Error updating backend token count: $e',
            name: 'TokenCubit');
      }
    } else {
      developer.log(
          'Token count has not been updated. No backend update needed.',
          name: 'TokenCubit');
    }
  }
}
