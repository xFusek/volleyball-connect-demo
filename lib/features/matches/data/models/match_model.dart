import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final String ownerId;
  final String header;
  final String location;
  final String description;
  final List<String> tags;
  final List<String> participants;
  final int maxParticipants;
  final String? customImageUrl;
  final DateTime? date;

  const MatchModel({
    required this.id,
    required this.ownerId,
    required this.header,
    required this.location,
    required this.description,
    required this.tags,
    required this.participants,
    required this.maxParticipants,
    this.customImageUrl,
    this.date,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MatchModel(
      id: doc.id,
      ownerId: data['userId'] ?? data['ownerId'] ?? '',
      header: data['header'] ?? 'Casual Volleyball Match',
      location: data['location'] ?? 'Unknown location',
      description: data['description'] ?? 'Join us for a friendly game!',
      tags: List<String>.from(data['tags'] ?? []),
      participants: List<String>.from(data['currentParticipants'] ?? []),
      maxParticipants: int.tryParse(data['maxParticipants']?.toString() ?? '12') ?? 12,
      customImageUrl: data['imageUrl'],
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }
}