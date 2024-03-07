import 'dart:io';

import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

enum AuthModeEnum { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() {
    return _AuthFormState();
  }
}

class _AuthFormState extends State<AuthForm> {
  final _form = GlobalKey<FormState>();
  AuthModeEnum _isLogin = AuthModeEnum.Login;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;

  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
    );
    if (email.trim().isNotEmpty && emailRegex.hasMatch(email)) return true;

    return false;
  }

  bool _isPasswordValid(String password) {
    if (password.trim().isNotEmpty && password.trim().length >= 6) return true;
    return false;
  }

  void _handleSignupLogin() async {
    try {
      if (_isLogin == AuthModeEnum.Login) {
        final userCridential = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else if (_isLogin == AuthModeEnum.Signup) {
        final userCridential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Authentication Failed!'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _submit() {
    final isValid = _form.currentState!.validate();

    if (!isValid) return;

    if (_isLogin == AuthModeEnum.Signup && _selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Please fill all the fields and select an image!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    _form.currentState!.save();
    _handleSignupLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLogin == AuthModeEnum.Signup)
            UserImagePicker(onSelectImage: (pickedImage) {
              _selectedImage = pickedImage;
            }),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email Address'),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              if (!_isEmailValid(value!)) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
            onSaved: (newValue) {
              _enteredEmail = newValue!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (!_isPasswordValid(value!)) {
                return 'Password must be at least  6 characters long.';
              }
              return null;
            },
            onSaved: (newValue) {
              _enteredPassword = newValue!;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer),
            icon: Icon(_isLogin == AuthModeEnum.Login
                ? Icons.login
                : Icons.app_registration_rounded),
            label: Text(_isLogin == AuthModeEnum.Login ? 'Login' : 'Signup'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = _isLogin == AuthModeEnum.Login
                    ? AuthModeEnum.Signup
                    : AuthModeEnum.Login;
              });
            },
            child: Text(_isLogin == AuthModeEnum.Login
                ? 'Create an account'
                : 'I already have an account.'),
          ),
        ],
      ),
    );
  }
}
