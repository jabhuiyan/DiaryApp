import 'package:dear_diaryv2/controller/diary_entry_service.dart';
import 'package:dear_diaryv2/reusable_widgets.dart';
import 'package:dear_diaryv2/view/color_utils.dart';
import 'package:dear_diaryv2/view/diary_list_view.dart';
import 'package:dear_diaryv2/view/forgotpassview.dart';
import 'package:dear_diaryv2/view/signupview.dart';
import 'package:flutter/material.dart';

// view for the login page
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  DiaryController controller = DiaryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).size.height * 0.2, 20, 0
            ),
            child: Column(
              children: <Widget>[
                const Text("Dear Diary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                reusableTextField("Enter Email", false, _emailTextController),
                const SizedBox(height: 20,),
                reusableTextField("Enter Password", true, _passwordTextController),
                const SizedBox(height: 20,),
                SignInUpButton(context, true, (){
                  controller.signIn(_emailTextController.text, _passwordTextController.text).then(
                      (value) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DiaryListView()));
                      }).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid Email or Password!'),
                          ),
                        );
                      });
                }),
                signUpOption(), // takes you to sign up page
                const SizedBox(height: 20,),
                ForgotPassOption() // takes you to forgot password page
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
        style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpView()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Row ForgotPassOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Forgot Password?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordView()));
          },
          child: const Text(
            " We Are here To Help",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
