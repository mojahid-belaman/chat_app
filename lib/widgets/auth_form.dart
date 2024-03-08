import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
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
  var _enteredUsername = '';
  var _enteredPassword = '';
  File? _selectedImage;
  bool _isAuth = false;

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

  bool _isUsermaneValid(String username) {
    if (username.isNotEmpty && username.trim().length >= 4) return true;
    return false;
  }

  void _handleSignupLogin() async {
    try {
      setState(() {
        _isAuth = true;
      });
      if (_isLogin == AuthModeEnum.Login) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else if (_isLogin == AuthModeEnum.Signup) {
        final userCridential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCridential.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        final userId = userCridential.user?.uid;
        FirebaseFirestore.instance.collection('users').doc('$userId}').set({
          'username': _enteredUsername,
          'imageUrl': imageUrl,
          'email': _enteredEmail
        });
        setState(() {
          _isAuth = false;
        });
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
      setState(() {
        _isAuth = false;
      });
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
            key: UniqueKey(),
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
          if (_isLogin == AuthModeEnum.Signup)
            TextFormField(
              decoration: const InputDecoration(labelText: 'Username'),
              enableSuggestions: false,
              validator: (value) {
                if (!_isUsermaneValid(value!)) {
                  return 'Please enter at least 4 carachters';
                }
                return null;
              },
              onSaved: (newValue) {
                _enteredUsername = newValue!;
              },
            ),
          TextFormField(
            key: UniqueKey(),
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
          if (_isAuth) const CircularProgressIndicator(),
          if (!_isAuth)
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
          if (!_isAuth)
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
