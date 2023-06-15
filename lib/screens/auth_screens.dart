import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chats_push/widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        _isLoading,
        submitFn: (
          String email,
          String username,
          String password,
          bool isLogin,
        ) async {
          UserCredential? authResult;

          try {
            setState(() {
              _isLoading = true;
            });
            if (isLogin) {
              authResult = await _auth
                  .signInWithEmailAndPassword(
                email: email,
                password: password,
              )
                  .catchError(
                (error) {
                  var message =
                      'An error occured,please check your credentials';

                  if (error.message != null) {
                    message = error.message!;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );

                  return authResult!;
                },
              );
            } else {
              authResult = await _auth
                  .createUserWithEmailAndPassword(
                email: email,
                password: password,
              )
                  .catchError(
                (error) {
                  var message =
                      'An error occured,please check your credentials';

                  if (error.message != null) {
                    message = error.message!;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );

                  return authResult!;
                },
              );
            }

            await FirebaseFirestore.instance
                .collection('users')
                .doc(authResult.user!.uid)
                .set({
              'username': username,
              'email': email,
            });
            setState(() {
              _isLoading = false;
            });
          } catch (err) {
            print(err);
            setState(() {
              _isLoading = false;
            });
          }
        },
      ),
    );
  }
}
