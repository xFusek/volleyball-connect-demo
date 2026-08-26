import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

class MatchesRepository {
  final FirebaseFirestore _firestore;

  MatchesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<MatchModel>> getMatchesStream() {
    return _firestore
        .collection('matches')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MatchModel.fromFirestore(doc))
              .toList(),
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

  Future<void> createMatch({
    required String header,
    required String description,
    required String location,
    required List<String> tags,
    required int maxParticipants,
    required String currency,
    required String userId,
  }) async {
    final matchData = {
      'createdAt': FieldValue.serverTimestamp(),
      'header': header,
      'description': description,
      'location': location,
      'tags': tags,
      'maxParticipants': maxParticipants,
      'currency': currency,
      'userId': userId,
      'currentParticipants': [userId],
    };

    final docRef = await _firestore.collection('matches').add(matchData);
    await docRef.update({'id': docRef.id});
  }

  Future<List<Map<String, dynamic>>> fetchParticipantsData(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return [];

    final snapshots = await Future.wait(
      userIds.map((id) => _firestore.collection('users').doc(id).get()),
    );

    return snapshots.map((doc) {
      final data = doc.data() ?? {};
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Volleyball Player',
        'image': data['image'] ?? '',
      };
    }).toList();
  }
}
