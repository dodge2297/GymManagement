import 'package:flutter/material.dart';
import 'package:gym_app/components/my_button.dart';
import 'package:gym_app/components/my_textfield.dart';
import 'package:gym_app/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  //debug code

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
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      final theme = ShadTheme.of(context);

      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Uh oh! Something went wrong'),
          description: const Text('Invalid email or password'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                //button
                MyButton(
                  onTap: signUserIn,
                  text: 'Sign In',
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
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text('Register now',
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
