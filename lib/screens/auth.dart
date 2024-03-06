import 'package:chat_app/widgets/auth_form.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, right: 20, bottom: 20, left: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              const Card(
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: AuthForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
