import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:date_spark_app/logger.dart';
import 'package:logging/logging.dart';

part 'token_state.dart';

final Logger _log = taggedLogger('TokenCubit');

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
        _log.fine('Loaded token count: $tokenCount');
        emit(state.copyWith(tokenCount: tokenCount));
      }
    } catch (e, stack) {
      _log.severe('Error loading token count', e, stack);
    }
  }

  Future<void> addTokens(int amount) async {
    try {
      var currentTokenCount = state.tokenCount;

      if (currentTokenCount + amount <= 3) {
        await _storage.write(key: 'tokenUpdated', value: 'true');
        currentTokenCount += amount;
        _log.fine('Token count increased: $currentTokenCount (+$amount)');

        await _storage.write(
            key: 'tokenCount', value: currentTokenCount.toString());

        emit(state.copyWith(
          tokenCount: currentTokenCount,
          tokenLimitReached: false,
          tokenUpdated: true,
        ));
      } else {
        _log.warning('Token limit reached');
        emit(state.copyWith(
          tokenLimitReached: true,
          timstamp: DateTime.now().toIso8601String(),
        ));
      }
    } catch (e, stack) {
      _log.severe('Error adding tokens', e, stack);
    }
  }

  Future<void> useTokens(int amount) async {
    try {
      var currentTokenCount = state.tokenCount;

      if (currentTokenCount >= amount) {
        await _storage.write(key: 'tokenUpdated', value: 'true');
        currentTokenCount -= amount;
        _log.fine('Token count decreased: $currentTokenCount (-$amount)');

        await _storage.write(
            key: 'tokenCount', value: currentTokenCount.toString());

        emit(state.copyWith(
          tokenCount: currentTokenCount,
          tokenLimitReached: false,
        ));
      } else {
        _log.warning('Not enough tokens');
      }
    } catch (e, stack) {
      _log.severe('Error using tokens', e, stack);
    }
  }
}
