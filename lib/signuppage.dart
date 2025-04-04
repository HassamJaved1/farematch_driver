import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farematch_driver/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'loginpage.dart';
import '../global.dart';
import 'package:firebase_database/firebase_database.dart';

import '../global.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  validateSgnForm() {
    if (fullNameController.text.trim().length < 3) {
      associateMethods.showSnackBarMsg(
          "Name must be at least 3 or more characters", context);
    } else if (!emailController.text.contains('@')) {
      associateMethods.showSnackBarMsg("Email is not valid", context);
    } else if (phoneController.text.trim().length < 9) {
      associateMethods.showSnackBarMsg(
          "Phone number must be 9 or more numbers", context);
    } else if (passwordController.text.trim().length < 5) {
      associateMethods.showSnackBarMsg(
          "Password must be at least 5 or more characters", context);
    } else {
      signUserNow();
    }
  }

  signUserNow() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Please wait...."));

    try {
      final User? firebaseUser = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim()))
          .user;

      Map<String, dynamic> userDataMap = {
        "name": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "password": passwordController.text.trim(),
        "id": firebaseUser!.uid,
        "blockStatus": "no",
      };

      FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser.uid)
          .set(userDataMap);

      Navigator.pop(context);
      associateMethods.showSnackBarMsg("Account created successfully", context);
    } catch (e) {
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
                    'Create Account',
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
                    'Create your account for eco-friendly rides',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: fullNameController,
                  hintText: 'Enter your full name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Your email address',
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: phoneController,
                  hintText: 'Your phone number',
                  icon: Icons.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Create a password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                      activeColor: Colors.teal,
                    ),
                    const Text(
                      'I agree with Terms & Conditions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      validateSgnForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
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
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already registered? ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log In',
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
