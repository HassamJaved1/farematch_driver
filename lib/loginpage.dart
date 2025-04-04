// ignore_for_file: use_build_context_synchronously

import 'package:farematch_driver/homepage.dart';
import 'package:farematch_driver/signuppage.dart';
import 'package:farematch_driver/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../global.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  validateSignInForm() {
    if (!emailController.text.contains('@')) {
      associateMethods.showSnackBarMsg("Email is not valid", context);
    } else if (passwordController.text.trim().length < 5) {
      associateMethods.showSnackBarMsg(
          "Password must be at least 5 characters", context);
    } else {
      signInUserNow();
    }
  }

  signInUserNow() async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Please wait..."),
    );
    try {
      final User? firebaseUser = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim())
              // ignore: body_might_complete_normally_catch_error
              .catchError((onError) {
        Navigator.pop(context);
        associateMethods.showSnackBarMsg(onError.toString(), context);
      }))
          .user;

      if (firebaseUser != null) {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(firebaseUser.uid);
        await ref.once().then((dataSnapshot) {
          if (dataSnapshot.snapshot.value != null) {
            if ((dataSnapshot.snapshot.value as Map)["blockStatus"] == "no") {
              userName = (dataSnapshot.snapshot.value as Map)["name"];
              userPhone = (dataSnapshot.snapshot.value as Map)["phone"];

              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => HomePage()));

              associateMethods.showSnackBarMsg(
                  "Logged in successfully", context);
            } else {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              associateMethods.showSnackBarMsg(
                  "You are blocked. Contact Admin: 21011598-154@uog.edu.pk",
                  context);
            }
          } else {
            Navigator.pop(context);
            FirebaseAuth.instance.signOut();
            associateMethods.showSnackBarMsg(
                "Your record does not exist as a user", context);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      FirebaseAuth.instance.signOut();
      associateMethods.showSnackBarMsg(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Welcome back! Please log in to your account.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Your email address',
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      validateSignInForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
