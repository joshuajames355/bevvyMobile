import 'package:bevvymobile/changeEmail.dart';
import 'package:bevvymobile/changePassword.dart';
import 'package:bevvymobile/homeNavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      bottomNavigationBar: HomeNavBar(
        currentIndex: 2,
      ),
      body: Container
      (
        padding: EdgeInsets.all(25),
        child: Column
        (
          children: [
            FlatButton
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
            Container
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
            (user.providerData.where((UserInfo x) => x.providerId=="password").length == 0) ? Container() :
            RaisedButton
            (
              color: Theme.of(context).primaryColor,
              child: Container
              (
                width: double.infinity,
                child: Center(child: Text("Change Password"),),
              ),
              onPressed: ()
              {
                showDialog(context: context, builder: (context) => ChangePassword(user: user)).then((x){
                  if(x == true)
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Success"), content: Text("Your password has been changed.")));
                  }
                });
              },
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
            ]
        )
      )
    );
  }
}