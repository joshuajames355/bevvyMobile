import 'package:bevvymobile/changeEmail.dart';
import 'package:bevvymobile/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef void VoidFunc();

class AccountDetails extends StatelessWidget
{
  const AccountDetails({ Key key, this.user, this.onUserChange, this.userDocument}) : super(key: key);

  final FirebaseUser user;
  final VoidFunc onUserChange;
  final DocumentSnapshot userDocument;

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar
      (
        title: Text("Account Details"),
      ),
      body: Column
      (
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 25, 10, 0),
            child: FlatButton
            (
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: 
                [
                  Text("Email:", style: TextStyle(fontSize: 18),),
                  Text((userDocument.data["personalDetails"] == null ? "Not Set"  : (userDocument.data["personalDetails"]["emailAddress"] ?? "Not Set")), style: TextStyle(fontSize: 18),),
                ]
              ),
              onPressed: ()
              {
                showDialog(context: context, builder: (context) => ChangeEmail(user: user)).then((var x)
                {
                  if(x == true)
                  {
                    onUserChange();
                  }
                });
              },
            ),
          ),
          Padding
          (
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Container
            (
              margin: EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.centerLeft,
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: 
                [
                  Text("Phone No:", style: TextStyle(fontSize: 18),),
                  Text(( user.phoneNumber ?? "Not Set"), style: TextStyle(fontSize: 18),),
                ]
              )            
            ),
          ),
          Card(
            child: FlatButton(
              child: Container(
                width: double.infinity,
                child: Text("Payment Methods")
              ),
              onPressed: () => Navigator.pushNamed(context, "/paymentMethods"),
            ),
          ),
          Expanded(child: Container()),//Fill space
          Card(
            child: FlatButton(
              onPressed: (){
                showPlatformDialog(context: context,
                          builder: (context) {
                            return PlatformAlertDialog(
                              content: Text("Are you sure you want to log out?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Close'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                FlatButton(
                                  child: Text('Confirm'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    auth.signOut();
                                  },
                                )
                              ]);
                          });
              },
              child: Container(
                margin: EdgeInsets.all(12),
                width: double.infinity,
                child: Text("Log Out"),),
            )
          )
        ]
      )
    );
  }
}