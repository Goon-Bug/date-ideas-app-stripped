part of 'token_cubit.dart';

class TokenState extends Equatable {
  final int tokenCount;
  final bool tokenLimitReached;
  final bool tokenUpdated;
  final String? timstamp;

  const TokenState(
      {required this.tokenCount,
      this.tokenLimitReached = false,
      this.tokenUpdated = false,
      this.timstamp});

  factory TokenState.initial() {
    return TokenState(tokenCount: 0);
  }

  TokenState copyWith(
      {int? tokenCount,
      bool? tokenLimitReached,
      bool? tokenUpdated,
      String? timstamp}) {
    return TokenState(
      tokenCount: tokenCount ?? this.tokenCount,
      tokenLimitReached: tokenLimitReached ?? this.tokenLimitReached,
      tokenUpdated: tokenUpdated ?? this.tokenUpdated,
      timstamp: timstamp ?? this.timstamp,
    );
  }

  @override
  List<Object> get props =>
      [tokenCount, tokenLimitReached, tokenUpdated, timstamp ?? ''];
}
