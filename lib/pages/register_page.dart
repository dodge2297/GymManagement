import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/components/my_button.dart';
import 'package:gym_app/components/my_textfield.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:gym_app/components/square_tile.dart';
import 'routes.dart';

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

  Future<void> signUserUp() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (passwordController.text.trim() ==
          confirmPasswordController.text.trim()) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginRegister);
        }
      } else {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
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
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Error'),
          description: Text(e.message ?? 'Something went wrong'),
        ),
      );
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
                const SizedBox(height: 10),
                const Text('Welcome to the club!',
                    style: TextStyle(fontSize: 20, color: Colors.black87)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true),
                ),
                const SizedBox(height: 20),
                MyButton(onTap: signUserUp, text: 'Sign Up'),
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
                    Text('Already a member?',
                        style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 3),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Login now',
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
