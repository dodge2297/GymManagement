import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_track/components/my_button.dart';
import 'package:gym_track/components/my_textfield.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_track/pages/adminpage.dart';
import 'package:gym_track/pages/homepage.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  // Sign in with email and password
  Future<void> signUserIn() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Fetch user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Check if the account is disabled
      final isDisabled = userDoc.get('isDisabled') ?? false;
      if (isDisabled) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _isLoading = false;
        });
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Account Disabled'),
            description: Text('Your account has been disabled by an admin.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Fetch user role
      final isAdmin = userDoc.get('isAdmin') ?? false;
      print('Login - User isAdmin: $isAdmin');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Success'),
            description: const Text('Logged in successfully'),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate based on role
        if (isAdmin) {
          print('Navigating to AdminPage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        } else {
          print('Navigating to HomePage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Something went wrong';
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts, please try again later';
            break;
        }

        final theme = ShadTheme.of(context);
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Uh oh! Something went wrong'),
            description: Text(errorMessage),
            action: ShadButton.destructive(
              child: const Text('Try again'),
              decoration: ShadDecoration(
                border: ShadBorder.all(
                    color: theme.colorScheme.destructiveForeground),
              ),
              onPressed: () => ShadToaster.of(context).hide(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final theme = ShadTheme.of(context);
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Uh oh! Something went wrong'),
            description: Text(e.toString()),
            action: ShadButton.destructive(
              child: const Text('Try again'),
              decoration: ShadDecoration(
                border: ShadBorder.all(
                    color: theme.colorScheme.destructiveForeground),
              ),
              onPressed: () => ShadToaster.of(context).hide(),
            ),
          ),
        );
      }
    }
  }

  // Reset password method
  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Error'),
          description: Text('Please enter your email address'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Password Reset'),
            description: const Text('Password reset email sent successfully'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred';
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Invalid email format';
            break;
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          default:
            errorMessage = e.message ?? 'An error occurred';
        }

        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text(errorMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
                    onPressed: _isLoading ? null : resetPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 10),
                MyButton(
                  onTap: _isLoading ? null : signUserIn,
                  text: 'Sign In',
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Signing In...',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : null,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
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
}
