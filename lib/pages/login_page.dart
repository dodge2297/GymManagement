import 'package:flutter/material.dart';
import 'package:gym_app/components/my_button.dart';
import 'package:gym_app/components/my_textfield.dart';
import 'package:gym_app/components/square_tile.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  LoginPage({super.key});

  //user sign-in

  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
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
                  Text('Register now', style: TextStyle(color: Colors.blue))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
