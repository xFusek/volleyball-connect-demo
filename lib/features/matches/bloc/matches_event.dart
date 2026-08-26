import 'package:equatable/equatable.dart';

abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => [];
}

class MatchesSubscriptionRequested extends MatchesEvent {}

class MatchesCreateRequested extends MatchesEvent {
  final String header;
  final String description;
  final String location;
  final List<String> tags;
  final int maxParticipants;
  final String currency;

  const MatchesCreateRequested({
    required this.header,
    required this.description,
    required this.location,
    required this.tags,
    required this.maxParticipants,
    required this.currency,
  });

  @override
  List<Object?> get props => [
        header,
        description,
        location,
        tags,
        maxParticipants,
        currency,
      ];
}

class MatchesToggleParticipationRequested extends MatchesEvent {
  final String matchId;
  final bool isCurrentlyJoined;

  const MatchesToggleParticipationRequested({
    required this.matchId,
    required this.isCurrentlyJoined,
  });

  @override
  List<Object?> get props => [matchId, isCurrentlyJoined];
}

class MatchesDeleteRequested extends MatchesEvent {
  final String matchId;

  const MatchesDeleteRequested(this.matchId);

  @override
  List<Object?> get props => [matchId];
}