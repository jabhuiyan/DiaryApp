import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// shows the Statistics of diary entries
// Note: so far, only shows the average of ratings
class StatisticsView extends StatefulWidget {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  _StatisticsViewState createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double averageRating = 0.0;
  String roundedAvg = '';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return;
    }

    // get the diary entries for the user
    final QuerySnapshot diaryEntries = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('diary_entries')
        .get();


    double totalRating = 0.0;
    int entryCount = 0;

    // calculate the average rating.
    for (final QueryDocumentSnapshot entry in diaryEntries.docs) {
      final Map<String, dynamic> data = entry.data() as Map<String, dynamic>;
      final int rating = data['rating'] as int;
      totalRating += rating;
      entryCount++;
    }

    // if there are entries, find the average
    if (entryCount > 0) {
      averageRating = totalRating / entryCount;
      roundedAvg = averageRating.toStringAsFixed(2);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Average Rating So Far: $roundedAvg',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}


