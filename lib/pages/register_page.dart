import 'package:flutter/material.dart';
import 'package:gym_app/components/my_button.dart';
import 'package:gym_app/components/my_textfield.dart';
import 'package:gym_app/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/pages/login_page.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Close the loading dialog
        Navigator.pop(context);

        // Navigate to login page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage(
                    onTap: widget.onTap,
                  )),
        );
      } else {
        Navigator.pop(context);
        final theme = ShadTheme.of(context);

        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Uh oh! Something went wrong'),
            description: const Text('Passwords do not match'),
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
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
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
                SizedBox(height: 15),

                Image.asset(
                  'lib/images/logo.png',
                  height: 150,
                ),

                Text(
                  'Welcome to the club!',
                  style: TextStyle(color: Colors.grey[800], fontSize: 20),
                ),

                SizedBox(
                  height: 20,
                ),

                //Email input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),
                ),

                SizedBox(height: 10),

                //Password input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true),
                ),

                SizedBox(height: 10),

                //Confirm Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextfield(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true),
                ),

                SizedBox(height: 10),

                SizedBox(
                  height: 20,
                ),

                //button
                MyButton(
                  onTap: signUserUp,
                  text: 'Sign Up',
                ),

                SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text('Or continue with'),
                      Expanded(
                          child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      )),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google sign-in
                    SquareTile(imagePath: 'lib/images/google.png'),
                  ],
                ),

                SizedBox(
                  height: 30,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text('Login now',
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
