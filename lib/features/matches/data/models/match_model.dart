import 'package:cloud_firestore/cloud_firestore.dart';

const Map<String, String> kLocationImages = {
  'ulica Ignacego Rzeckiego 10, Lublin':
      'assets/icons/matches/gleboka31.jpg',
  'Aleja Jana Długosza 8a, Lublin':
      'assets/icons/matches/aleja_jana_dlugosza.jpg',
  'ulica Doktora Kazimierza Jaczewskiego 5, Lublin':
      'assets/icons/matches/konstantynow.jpg',
};

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
  final String currency;

  const MatchModel({
    required this.id,
    required this.ownerId,
    required this.header,
    required this.location,
    required this.description,
    required this.tags,
    required this.participants,
    required this.maxParticipants,
    this.currency = 'Free',
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
      maxParticipants:
          int.tryParse(data['maxParticipants']?.toString() ?? '12') ?? 12,
      currency: data['currency'] ?? 'Free',
      customImageUrl: data['imageUrl'],
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }
}
