import 'package:bevvymobile/firebase.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef void OnLogout();

class AccountDetails extends StatelessWidget
{
  const AccountDetails({ Key key, this.user, this.onLogout}) : super(key: key);

  final FirebaseUser user;
  final OnLogout onLogout;


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar
      (
        title: Text("Account Details"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container
      (
        padding: EdgeInsets.all(25),
        color: Theme.of(context).backgroundColor,
        child: Column
        (
          children: [
            Container
            (
              margin: EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.centerLeft,
              child: Text("Email: " + user.email, style: TextStyle(fontSize: 18),),
            ),
            Expanded(child: Container()),//Fill space
            RaisedButton
            (
              color: Theme.of(context).primaryColor,
              child:  Container
              (
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center
                (
                  child: Text("Logout", style: TextStyle(fontSize: 18),)
                  ),
                width: double.infinity,
              ),
              onPressed: ()
              {
                auth.signOut().then((x)
                {
                  onLogout();
                  Navigator.pop(context);
                });
              },
            )
            ]
        )
      )
    );
  }
}