import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/components/my_button.dart';
import 'package:gym_app/components/my_textfield.dart';
import 'package:gym_app/components/square_tile.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('lib/images/logo.png'), context);
    precacheImage(const AssetImage('lib/images/google.png'), context);
  }

  void signUserUp() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final theme = ShadTheme.of(context);
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Uh oh! Something went wrong'),
            description: const Text('Passwords do not match'),
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
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user?.reload();
      await Future.delayed(const Duration(milliseconds: 500));
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('User authentication not available after registration');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'age': '',
        'phone': '',
        'address': '',
        'countryCode': '+1',
        'bloodGroup': null,
        'profileImage': null,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'isDisabled': false,
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Success'),
            description: const Text('Registered successfully. Please log in.'),
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        print('Navigating to login page');
        if (widget.onTap != null) widget.onTap!();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        String errorMessage = 'Something went wrong';
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email already in use';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
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
                    controller: nameController,
                    hintText: 'Full Name',
                    obscureText: false,
                  ),
                ),
                const SizedBox(height: 10),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  onTap: _isLoading ? null : signUserUp,
                  text: _isLoading ? 'Registering...' : 'Register',
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
                    SquareTile(imagePath: 'lib/images/google.png'),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already a member?',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 3),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
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
    confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
