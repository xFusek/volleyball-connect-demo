import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';

class MatchesRepository {
  final FirebaseFirestore _firestore;

  MatchesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<MatchModel>> getMatchesStream() {
    return _firestore.collection('matches').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> toggleParticipation({
    required String matchId,
    required String userId,
    required bool isCurrentlyJoined,
  }) async {
    final matchRef = _firestore.collection('matches').doc(matchId);
    if (isCurrentlyJoined) {
      await matchRef.update({
        'currentParticipants': FieldValue.arrayRemove([userId]),
      });
    } else {
      await matchRef.update({
        'currentParticipants': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<void> deleteMatch(String matchId) async {
    await _firestore.collection('matches').doc(matchId).delete();
  }
}