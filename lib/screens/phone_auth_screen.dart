import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/services.dart';

class PhoneAuthScreen extends StatefulWidget {
  static const routeName = '/phone-auth-screen';
  const PhoneAuthScreen({Key key}) : super(key: key);

  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _checkLoginState(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (snapshot.hasData) {
              var user = snapshot.data as FirebaseAuth.User;
              return Column(
                children: [
                  snapshot.hasData ? Text('Logged in user is: + ${user.phoneNumber ?? ''}') : Text('To use this application please validate your phone number'),
                  if (!snapshot.hasData)
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        child: Text('Proceed'),
                        onPressed: _processLogin,
                      ),
                    )
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Future<FirebaseAuth.User> _checkLoginState() async {
    return FirebaseAuth.FirebaseAuth.instance.currentUser;
  }

  void _processLogin() async {
    String error = "";
    var user = FirebaseAuth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      FirebaseAuthUi.instance().launchAuth([
        AuthProvider.phone(),
      ]).then((value) {
        error = "";
      }).catchError((e) {
        if (e is PlatformException) {
          if (e.code == FirebaseAuthUi.kUserCancelledError) {
            error = "User cancelled login";
          } else {
            error = e.message ?? 'Unknown error';
          }
        }
      });
    }
  }
}
