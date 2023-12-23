import 'package:dear_diaryv2/controller/diary_entry_service.dart';
import 'package:dear_diaryv2/view/diary_list_view.dart';
import 'package:flutter/material.dart';

import '../reusable_widgets.dart';
import 'color_utils.dart';

// view for sign up page
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  DiaryController controller = DiaryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [
          hexStringToColor("CB2B93"),
          hexStringToColor("9546C4"),
          hexStringToColor("5E61F4")
        ])),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                reusableTextField("Enter Email", false, _emailTextController),
                const SizedBox(height: 20,),
                reusableTextField("Enter Password", true, _passwordTextController),
                const SizedBox(height: 20,),
                SignInUpButton(context, false, (){
                  controller.signUp(_emailTextController.text, _passwordTextController.text).then(
                      (value) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DiaryListView()));
                      }).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$error'),
                          ),
                        );
                      });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
