import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repository/matches_repository.dart';
import 'matches_event.dart';
import 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final MatchesRepository _repository;

  MatchesBloc(this._repository) : super(const MatchesState()) {
    on<MatchesSubscriptionRequested>(_onSubscriptionRequested);
    on<MatchesCreateRequested>(_onCreateRequested);
    on<MatchesToggleParticipationRequested>(_onToggleParticipationRequested);
    on<MatchesDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onSubscriptionRequested(
    MatchesSubscriptionRequested event,
    Emitter<MatchesState> emit,
  ) async {
    emit(state.copyWith(status: MatchesStatus.loading));
    await emit.forEach(
      _repository.getMatchesStream(),
      onData: (matches) => state.copyWith(
        status: MatchesStatus.success,
        matches: matches,
      ),
      onError: (error, _) => state.copyWith(
        status: MatchesStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }

  Future<void> _onCreateRequested(
    MatchesCreateRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    emit(state.copyWith(isActionInProgress: true));
    try {
      await _repository.createMatch(
        header: event.header,
        description: event.description,
        location: event.location,
        tags: event.tags,
        maxParticipants: event.maxParticipants,
        currency: event.currency,
        userId: userId,
      );
      emit(state.copyWith(isActionInProgress: false));
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleParticipationRequested(
    MatchesToggleParticipationRequested event,
    Emitter<MatchesState> emit,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await _repository.toggleParticipation(
        matchId: event.matchId,
        userId: userId,
        isCurrentlyJoined: event.isCurrentlyJoined,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    MatchesDeleteRequested event,
    Emitter<MatchesState> emit,
  ) async {
    emit(state.copyWith(isActionInProgress: true));
    try {
      await _repository.deleteMatch(event.matchId);
      emit(state.copyWith(isActionInProgress: false));
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: e.toString(),
      ));
    }
  }
}