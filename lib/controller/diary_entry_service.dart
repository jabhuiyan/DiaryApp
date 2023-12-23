import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../model/diary_entry_model.dart';

// controller for Diary entries
class DiaryController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // function t log in a user
  Future<User?> signIn(String email, String password) async {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // function to sign up a user
  Future<User?> signUp(String email, String password) async {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
    );
    return userCredential.user;
  }

  // function to sign out a user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // function to send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // function to add a diary entry to the firestore database
  Future<void> addDiaryEntry(DiaryEntry entry, String userUid) async {
    await _firestore.collection('users').doc(userUid).collection('diary_entries').add({
      'date': entry.date,
      'description': entry.description,
      'rating': entry.rating,
      'imageUrls': entry.imageUrls,
    });
  }

  // function get all diary entries of a user from the firestore database
  Future<List<DiaryEntry>> fetchDiaryEntries(String userUid) async {
    final querySnapshot = await _firestore
        .collection('diary_entries')
        .where('uid', isEqualTo: userUid)
        .get();

    final entries = querySnapshot.docs
        .map((doc) => DiaryEntry.fromSnapshot(doc))
        .toList();

    return entries;
  }

  // function to update a diary entry to the firestore database
  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('diary_entries').doc('Edit Diary Entry').set(entry.toMap());
  }

  // function to delete a diary entry from the firestore database
  Future<void> removeDiaryEntry(String entryId) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('diary_entries').doc(entryId).delete();
  }

  Future<String?> uploadImage(XFile? image) async {
    final user = _auth.currentUser?.uid;
    final storageReference = FirebaseStorage.instance.ref().child('images/$user/${image!.name}');
    await storageReference.putFile(File(image!.path));
    final String downloadURL = await storageReference.getDownloadURL();
    print('Uploaded to: $downloadURL');
    return downloadURL;
  }
}