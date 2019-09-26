import 'package:bevvymobile/changeEmail.dart';
import 'package:bevvymobile/changePassword.dart';
import 'package:bevvymobile/globals.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef void VoidFunc();

class AccountDetails extends StatelessWidget
{
  const AccountDetails({ Key key, this.user, this.onLogout, this.onUserChange}) : super(key: key);

  final FirebaseUser user;
  final VoidFunc onLogout;
  final VoidFunc onUserChange;

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
            FlatButton
            (
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: 
                [
                  Text("Email:", style: TextStyle(fontSize: 18),),
                  Text(( user.email ?? "Not Set"), style: TextStyle(fontSize: 18),),
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
            (user.isEmailVerified ? Container() : 
            Container
            (
              margin: EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.centerLeft,
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: 
                [ 
                  Text("Email Not Verified", style: TextStyle(fontSize: 18)),
                  RaisedButton
                  (
                    color: Theme.of(context).primaryColor,
                    onPressed: ()
                    {
                      user.sendEmailVerification().then((x) 
                      {
                        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Success"), content: Text("Email Verification Sent")));
                      }).catchError((e)
                      {
                        if(e.code == "ERROR_TOO_MANY_REQUESTS")
                        {
                          showDialog(context: context, builder: (context) => AlertDialog(title: Text("ERROR"), content: Text("Too many requests, please try again later.")));
                        }
                        else
                        {
                          showDialog(context: context, builder: (context) => AlertDialog(title: Text("ERROR"), content: Text(e.code)));
                        }
                      });
                    },
                    child: Text("Resend Email"),
                  )
                ]
              )
            )),
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
                Navigator.pop(context);
                auth.signOut().then((x)
                {
                  onLogout();
                });
              },
            )
            ]
        )
      )
    );
  }
}