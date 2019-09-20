import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:bevvymobile/firebase.dart';
import 'package:bevvymobile/loginEmail.dart';
import 'package:bevvymobile/loginPhone.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();


class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.onLogin}) : super(key: key);

  final OnLogin onLogin;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (
        title: Text("Sign Up or Log in"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
          ),
      ),
      body: Center(
        child: Padding
        (
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GoogleSignInButton
              (
                onPressed: () async
                {
                  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
                  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
                  final AuthCredential credential = GoogleAuthProvider.getCredential
                  (
                    accessToken: googleAuth.accessToken,
                    idToken: googleAuth.idToken,
                  );
                  final FirebaseUser user = (await auth.signInWithCredential(credential)).user;
                  widget.onLogin(user);
                },
              ),
              Container 
              (
                  width: double.infinity,
                  child: RaisedButton(
                        onPressed: (){
                          showDialog(context: context, builder: (BuildContext context)
                          {
                            return LoginEmailPage(onLogin: widget.onLogin,);
                          });
                      },
                      color: Colors.red,
                      padding: EdgeInsets.all(7),
                      child: Row(children: <Widget>
                      [
                        Padding
                        (
                          child: Icon(IconData(57534, fontFamily: 'MaterialIcons'), color: Colors.white,), 
                          padding: EdgeInsets.only(right: 25),
                        ),
                        Text(
                            "Sign in with Email",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                        ),                        
                      ])
                  )
              ),
              Container 
              (
                width: double.infinity,
                child: RaisedButton(
                  onPressed: (){
                    showDialog(context: context, builder: (BuildContext context)
                    {
                      return LoginPhonePage(onLogin: widget.onLogin,);
                    });
                  },
                  color: Colors.lightGreen,
                  padding: EdgeInsets.all(7),
                  child: Row
                  (
                    children: <Widget>
                    [
                      Padding
                      (
                        child: Icon(IconData(58705, fontFamily: 'MaterialIcons'), color: Colors.white,), 
                        padding: EdgeInsets.only(right: 25),
                      ),

                      Text(
                        "Sign in with Phone",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),                        
                    ]
                  )
                )
              ),
            ],
          ),
        )
      ),
    );
  }

    @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }
}

