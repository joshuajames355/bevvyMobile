import 'package:flutter/material.dart';
import 'dart:developer';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage(
                    'images/icon.jpg',
                    ),
            ),
            TextField(
                autofocus: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                ),
            ),
            TextField(
                autofocus: false,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                ),
            ),
            new Container (
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10.0),
                child: RaisedButton(
                    onPressed: (){
                        log("Press");
                    },
                    padding: const EdgeInsets.all(15),
                    child: Text(
                        "Login",
                        style: TextStyle(fontSize: 20.0),
                    ),
                )
            ),
            new Container (
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10.0),
                child: RaisedButton(
                    onPressed: (){
                        log("Press");
                    },
                    padding: const EdgeInsets.all(15),
                    child: Text(
                        "Create Account",
                        style: TextStyle(fontSize: 20.0),
                    ),
                )
            ),
            new Container (
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10.0),
                child: FlatButton(
                    onPressed: (){
                        log("Press");
                    },
                    padding: const EdgeInsets.all(15),
                    child: Text(
                        "Forgotten Password",
                        style: TextStyle(fontSize: 20.0),
                    ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
