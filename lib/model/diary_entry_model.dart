import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntry {
  final String id; // document ID
  final String uid; // user ID
  final String date;
  final String description;
  final int rating;
  final String imageUrls;

  DiaryEntry({
    required this.id,
    required this.uid,
    required this.date,
    required this.description,
    required this.rating,
    required this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'rating': rating,
      'imageUrls': imageUrls,
    };
  }

  factory DiaryEntry.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: snapshot.id,
      uid: data['uid'],
      date: data['date'].toDate(),
      description: data['description'],
      rating: data['rating'],
      imageUrls: '',
    );
  }
}

