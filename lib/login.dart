import 'package:flutter/material.dart';
import 'dart:developer';
import "config.dart";
import 'package:http/http.dart' as http;

typedef VoidFunction = void Function();

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.onBack}) : super(key: key);

  final VoidFunction onBack;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

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
            this.widget.onBack();
          },
          ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Image(
                  image: AssetImage(
                      'images/icon.jpg',
                      ),
              ),
            ),
            TextField(
                autofocus: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                ),
                controller: emailTextController,
            ),
            TextField(
                autofocus: false,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                ),
                controller: passwordTextController,
            ),
            new Container (
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10.0),
                child: RaisedButton(
                    onPressed: () {},
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

    @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailTextController.dispose();
    super.dispose();
  }

    Future<http.Response> onLogin(String apiBaseUrl) {
      return http.post(apiBaseUrl + "/login", body: '{"email":"' + emailTextController.text + '","password":"' + passwordTextController.text +'"}', headers: {'Content-type': 'application/json'});
    }
  }

