import 'package:flutter/material.dart';
import 'package:bevvymobile/reauthenticate.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeEmail extends StatefulWidget
{
  const ChangeEmail({ Key key, this.user}) : super(key: key);

  final FirebaseUser user;

  @override
  _ChangeEmailState createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail>
{
  TextEditingController _newEmailController = new TextEditingController();

  @override 
  Widget build(BuildContext context)
  {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
      ),      
      title: Center(child: Text("Change Email")),
      children: dialogContent(context),
      contentPadding: EdgeInsets.all(7),
    );
  }

  List<Widget> dialogContent(BuildContext context) 
  {
    return
    [
      TextField
      (
        autofocus: true,
        controller: _newEmailController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 5)
          ),
          labelText: 'New Email',
        ),   
        onSubmitted: (String x) 
        {
          changeEmail();
        },       
      ),
      RaisedButton
      (
        child: Container
        (
          width: double.infinity,
          padding: EdgeInsets.all(12),
          child: Text("Change Email"),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: changeEmail,
      )
    ];
  }

  changeEmail()
  {
    widget.user.updateEmail(_newEmailController.text).then((x)
    {
      Navigator.pop(context, true);
    }).catchError((error)
    {
      if(error.code == "ERROR_REQUIRES_RECENT_LOGIN")
      {
        reauthenticate(context, widget.user).then((x)
        {
          widget.user.updateEmail(_newEmailController.text).then((x)
          {
            Navigator.pop(context, true);
          }).catchError((error)
          {
            if(error.code == "ERROR_REQUIRES_RECENT_LOGIN")
            {
              showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Reauthentication Failed.")));
            }
            else if(error.code == "ERROR_INVALID_EMAIL")
            {
              showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Invalid Email.")));
            }
            else
            {
              showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text(error.code)));
            }
          });
        });
      }
      else if(error.code == "ERROR_INVALID_EMAIL")
      {
        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Invalid Email.")));
      }
      else
      {
        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text(error.code)));
      }
    });
  }
}
