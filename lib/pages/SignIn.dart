// SignIn.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_flutter/pages/HomePage.dart';
import 'auth_service.dart';
import 'SignUp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String error = '';

  void _navigateToHomePage(User user) {
    String lastName = user.displayName?.split(' ').last ?? 'User';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(lastName: lastName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              child: const Text('Sign In'),
              onPressed: () async {
                if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                  User? user = await _auth.signInWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (user == null) {
                    setState(() {
                      error = 'Could not sign in with those credentials';
                    });
                  } else {
                    _navigateToHomePage(user);
                  }
                } else {
                  setState(() {
                    error = 'Please enter email and password';
                  });
                }
              },
            ),

      ElevatedButton.icon(
          icon: FaIcon(FontAwesomeIcons.google, color: Colors.white),
      label: Text('Sign In with Google'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50), // full width
      ),
      onPressed: () async {
        User? user = await _auth.signInWithGoogle();
        if (user == null) {
          setState(() {
            error = 'Google Sign-In failed';
          });
        } else {
          _navigateToHomePage(user);
        }
      },
    ),
    SizedBox(height: 10), // Add some space between buttons
    ElevatedButton.icon(
    icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
    label: Text('Sign In with Facebook'),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue[800],
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 50), // full width
    ),
    onPressed: () async {
    User? user = await _auth.signInWithFacebook();
    if (user == null) {
    setState(() {
    error = 'Facebook Sign-In failed';
    });
    } else {
    _navigateToHomePage(user);
    }
    },
    ),
            TextButton(
              child: const Text('Don\'t have an account? Sign Up'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp()),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}