// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                autofocus: true,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  
                  int alphabetCount = value.replaceAll(RegExp(r'[^a-zA-Z]'), '').length;
                  int numberCount = value.replaceAll(RegExp(r'[^0-9]'), '').length;
                  
                  if (alphabetCount < 3 || numberCount < 3) {
                    return 'Username is invalid';
                  }
                  return null;
                },
              ),            
              
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  // if (value.length < 6) {
                  //   return 'Password must be at least 6 characters';
                  // }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Confirm Password doesn\'t match Password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Email Address',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  // if (!value.contains('@') || !value.contains('.')) {
                  //   return 'Please enter a valid email address';
                  // }
                  return null;
                },
              ),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('SIGN UP'),
                    onPressed: () {
                      // Validate the form before processing
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, show success message and navigate
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registration Successful!')),
                        );
                        // Navigate to Sign In page (login page)
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}