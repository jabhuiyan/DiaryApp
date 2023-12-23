import 'package:flutter/material.dart';
import '../reusable_widgets.dart';
import 'color_utils.dart';
import '../controller/diary_entry_service.dart';

// view page for Forgot password
class ForgotPasswordView extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordView({super.key});

  final DiaryController controller = DiaryController();

  void _resetPassword(BuildContext context) async {
    try {
      controller.sendPasswordResetEmail(_emailController.text).then(
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset email sent. Please check your email.'),
              ),
            );
          }
      ).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$error'),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error sending password reset email.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Forgotten Password", style: TextStyle(fontWeight: FontWeight.bold)),
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
                reusableTextField("Enter Email", false, _emailController),
                const SizedBox(height: 20,),
                ElevatedButton(onPressed: () => _resetPassword(context), child: const Text("Reset password"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}