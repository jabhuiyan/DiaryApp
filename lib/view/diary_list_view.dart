import 'package:dear_diaryv2/view/statisticsview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_diary_entry_view.dart';
import 'loginview.dart';
import '../controller/diary_entry_service.dart';

// View page that shows all the diary entries made
class DiaryListView extends StatefulWidget {
  const DiaryListView({super.key});

  @override
  _DiaryListViewState createState() => _DiaryListViewState();
}

class _DiaryListViewState extends State<DiaryListView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DiaryController controller = DiaryController();

  void _signOut() async {
    try {
      await _auth.signOut();
      // navigate to the login page after successful sign-out
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginView()));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // load view for adding a new entry
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditDiaryEntryView(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: (){
              // show statistics
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsView(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('diary_entries')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final entries = snapshot.data!.docs;
          if (entries.isEmpty) {
            return const Center(
              child: Text('No diary entries yet.'),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index].data() as Map<String, dynamic>;
              final entryId = entries[index].id;

              return ListTile(
                title: Text('Date: ${entry['date']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${entry['description']}'),
                    Text('Rating: ${entry['rating']} stars'),
                  ],
                ),
                leading: Container(
                  height: 80,
                  width: 80,
                  child: entry.containsKey('imageUrls') ? Image.network('${entry['imageUrls']}') : Container(),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // load view for editing a new entry
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditDiaryEntryView(
                              entryId: entryId,
                              isEditing: true,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // delete entry
                        controller.removeDiaryEntry(entryId);
                      },
                    ),
                  ],
                ),
              );
            },
          );

        },
      ),
    );
  }
}