import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add this import
import 'package:gym_app/components/my_button.dart';
import 'package:gym_app/components/my_textfield.dart';
import 'package:gym_app/components/square_tile.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Sign in with email and password
  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
    } on FirebaseAuthException {
      Navigator.pop(context);
      showErrorMessage('Invalid email or password');
    }
  }

  // Forgot password functionality
  void resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Password Reset'),
          description: const Text('Password reset email sent successfully'),
          duration: const Duration(seconds: 3),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.message ?? 'Error sending reset email');
    }
  }

  // Google Sign In functionality
  Future<void> signInWithGoogle() async {
    try {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        Navigator.pop(context);
        return; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage('Google Sign-In failed');
    }
  }

  // Helper method to show error messages
  void showErrorMessage(String message) {
    final theme = ShadTheme.of(context);
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: const Text('Uh oh! Something went wrong'),
        description: Text(message),
        action: ShadButton.destructive(
          child: const Text('Try again'),
          decoration: ShadDecoration(
            border: ShadBorder.all(
              color: theme.colorScheme.destructiveForeground,
            ),
          ),
          onPressed: () => ShadToaster.of(context).hide(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                Image.asset('lib/images/logo.png', height: 150),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resetPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 10),
                MyButton(onTap: signUserIn, text: 'Sign In'),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child:
                              Divider(thickness: 0.5, color: Colors.grey[400])),
                      const Text('Or continue with'),
                      Expanded(
                          child:
                              Divider(thickness: 0.5, color: Colors.grey[400])),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      imagePath: 'lib/images/google.png',
                      onTap: signInWithGoogle, // Add onTap handler
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 3),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Register now',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}