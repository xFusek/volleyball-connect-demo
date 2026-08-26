import 'package:equatable/equatable.dart';
import '../data/models/match_model.dart';

enum MatchesStatus { initial, loading, success, failure }

class MatchesState extends Equatable {
  final MatchesStatus status;
  final List<MatchModel> matches;
  final String? errorMessage;
  final bool isActionInProgress;

  const MatchesState({
    this.status = MatchesStatus.initial,
    this.matches = const [],
    this.errorMessage,
    this.isActionInProgress = false,
  });

  MatchesState copyWith({
    MatchesStatus? status,
    List<MatchModel>? matches,
    String? errorMessage,
    bool? isActionInProgress,
  }) {
    return MatchesState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      errorMessage: errorMessage,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }

  @override
  List<Object?> get props => [status, matches, errorMessage, isActionInProgress];
}