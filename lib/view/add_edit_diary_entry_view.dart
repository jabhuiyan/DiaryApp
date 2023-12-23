import 'dart:io';
import 'package:dear_diaryv2/model/diary_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/diary_entry_service.dart';
import 'package:image_picker/image_picker.dart';

// View page for adding and editing a diary entry
class AddEditDiaryEntryView extends StatefulWidget {
  final String? entryId;
  final bool isEditing;

  const AddEditDiaryEntryView({super.key, this.entryId, this.isEditing = false});

  @override
  _AddEditDiaryEntryViewState createState() => _AddEditDiaryEntryViewState();
}

class _AddEditDiaryEntryViewState extends State<AddEditDiaryEntryView> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DiaryController controller = DiaryController();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      // load the existing diary entry for editing
      _loadDiaryEntry(widget.entryId);
    } else {
      // initialize fields for adding a new entry
      dateController.text = DateTime.now().toLocal().toString().split(' ')[0];
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  // load a diary entry
  void _loadDiaryEntry(String? entryId) async {
    if (entryId == null) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
        ),
      );
      return;
    }

    final userId = user.uid;

    try {
      final diaryEntryDocument = await _firestore
          .collection('users')
          .doc(userId)
          .collection('diary_entries')
          .doc(entryId)
          .get();

      if (diaryEntryDocument.exists) {
        final data = diaryEntryDocument.data() as Map<String, dynamic>;
        dateController.text = data['date'];
        descriptionController.text = data['description'];
        ratingController.text = data['rating'].toString();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading diary entry: $e'),
        ),
      );
    }
  }

  // save a diary entry
  void _saveDiaryEntry() async {
    final String userId = _auth.currentUser!.uid;
    final String date = dateController.text;
    final String description = descriptionController.text;
    final int rating = int.tryParse(ratingController.text) ?? 0;

    if (date.isEmpty || description.isEmpty || rating < 1 || rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid input. Please check the values.'),
        ),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'date': date,
      'description': description,
      'rating': rating,
      'imageUrls': '',
    };

    try {

      if (widget.isEditing) {
        // update an existing diary entry
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('diary_entries')
            .doc(widget.entryId)
            .set(data);
      } else {
        // Upload image if available
        if (_image != null) {
          final imageUrl = await controller.uploadImage(_image);
          print('$imageUrl');

          if (imageUrl != null) {
            // add a new diary entry
            controller.addDiaryEntry(
                DiaryEntry(id: 'diary_entries', uid: userId, date: date, description: description, rating: rating, imageUrls: imageUrl), userId
            );
          } else {
            controller.addDiaryEntry(
                DiaryEntry(id: 'diary_entries', uid: userId, date: date, description: description, rating: rating, imageUrls: ''), userId
            );
          }
        } else {
          controller.addDiaryEntry(
              DiaryEntry(id: 'diary_entries', uid: userId, date: date, description: description, rating: rating, imageUrls: ''), userId
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diary entry saved successfully.'),
        ),
      );

      // navigate back to the homepage upon adding/editing a data
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving diary entry: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Diary Entry' : 'Add Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
              readOnly: true,
              onTap: () async {
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  dateController.text = selectedDate.toLocal().toString().split(' ')[0];
                }
              },
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description (140 characters or less)'),
              maxLength: 140,
            ),
            TextFormField(
              controller: ratingController,
              decoration: const InputDecoration(labelText: 'Rating (1 to 5 stars)'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: const Text('Upload from gallery'),
            ),
            ElevatedButton(
              onPressed: _pickImageFromCamera,
              child: const Text('Upload from camera'),
            ),
            if (_image != null)
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    height: 200,
                    width: 200,
                    child: Image.file(File(_image!.path)),
                  ),

                  // Button to remove the selected image
                  ElevatedButton(
                    onPressed: _clearImage,
                    child: const Text('Remove Image'),
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: _saveDiaryEntry,
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}