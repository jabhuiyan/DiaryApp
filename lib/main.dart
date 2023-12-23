import 'package:dear_diaryv2/view/add_edit_diary_entry_view.dart';
import 'package:dear_diaryv2/view/diary_list_view.dart';
import 'package:dear_diaryv2/view/loginview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  // initialize firebase first
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/diaryLog': (context) => const DiaryListView(),
        '/diaryEntry': (context) => const AddEditDiaryEntryView(),
      },
      title: 'Dear Diary',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey,
      ),
    );
  }
}
