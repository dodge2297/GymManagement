import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_app/components/my_button.dart';
import 'package:gym_app/components/my_textfield.dart';
import 'package:gym_app/components/square_tile.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app/pages/adminpage.dart';
import 'package:gym_app/pages/homepage.dart';

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
  void signUserIn() async {
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
  void resetPassword() async {
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

  // Sign in with Google
  void signInWithGoogle() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if user exists in Firestore, if not create a new entry
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'isAdmin': false,
          'isDisabled': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

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
      final isAdmin = userDoc.exists ? userDoc.get('isAdmin') ?? false : false;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Success'),
            description: const Text('Logged in with Google successfully'),
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
        String errorMessage = 'Google Sign-In failed';
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage = 'Account exists with different credentials';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid Google credentials';
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('An unexpected error occurred: $e'),
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
                    onPressed: resetPassword,
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
                      onTap: _isLoading ? null : signInWithGoogle,
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
