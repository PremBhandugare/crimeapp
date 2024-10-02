import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crimeapp/widgets/Uinputdecorat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth firebase = FirebaseAuth.instance;

class LoginScr extends StatefulWidget {
  const LoginScr({super.key});
  @override
  State<LoginScr> createState() => _LoginScrState();
}

class _LoginScrState extends State<LoginScr> {
  final usernCtlr = TextEditingController();
  final passCtlr = TextEditingController();
  final contCtlr = TextEditingController();
  final nameCtlr = TextEditingController();
  bool islogin = false;
  final formkey = GlobalKey<FormState>();
  String usrname = '';
  String passname = '';
  String contact = '';
  String name = '';
  bool isauthen = false;

  void submit() async {
    bool isvalid = formkey.currentState!.validate();
    if (!isvalid || (!islogin && (contCtlr.text.isEmpty || nameCtlr.text.isEmpty))) {
      return;
    }

    formkey.currentState!.save();
    if (islogin) {
      try {
        setState(() {
          isauthen = true;
        });
        final usercredntials = await firebase.signInWithEmailAndPassword(
          email: usrname,
          password: passname,
        );
        // print(usercredntials);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Handle the specific case if needed
        }
        setState(() {
          isauthen = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed.')),
        );
      }
    } else {
      try {
        setState(() {
          isauthen = true;
        });
        final usercredntials = await firebase.createUserWithEmailAndPassword(
          email: usrname,
          password: passname,
        );
        setState(() {
          isauthen = false;
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(usercredntials.user!.uid)
            .set({
          'email': usrname,
          'emergencyNumber': [contact],
          'fullName': name,
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Handle the specific case if needed
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed.')),
        );
        setState(() {
          isauthen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Card(
          color: Theme.of(context).colorScheme.onError,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            child: Column(
              children: [
                Text(
                  islogin ? 'Login' : 'Register',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      if (!islogin)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: nameCtlr,
                            obscureText: false,
                            decoration: customInputDecoration(hintText: 'Full name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name should not be null';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              name = value!;
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: usernCtlr,
                          decoration: customInputDecoration(
                            hintText: 'Email',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            usrname = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: passCtlr,
                          obscureText: true,
                          decoration: customInputDecoration(hintText: 'Password'),
                          validator: (value) {
                            if (value == null || value.trim().length < 8) {
                              return 'Password must be 8 characters long';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            passname = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!islogin)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: contCtlr,
                            obscureText: false,
                            decoration: customInputDecoration(hintText: 'Emergency Contact'),
                            validator: (value) {
                              if (value == null || value.trim().length != 10) {
                                return 'Phone number should be 10 digits';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              contact = value!;
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (isauthen) const CircularProgressIndicator(),
                      if (!isauthen)
                        ElevatedButton(
                          onPressed: submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            islogin ? 'Sign in' : 'Sign up',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      const SizedBox(height: 5),
                      if (!isauthen)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              islogin = !islogin;
                            });
                          },
                          child: Text(
                            islogin ? 'Create an account' : 'Already have an account',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
