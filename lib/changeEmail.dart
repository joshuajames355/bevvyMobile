import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
    Firestore.instance.collection('users').document(widget.user.uid).updateData({
      'personalDetails.emailAddress': _newEmailController.text,
    }).then((_) {
      Navigator.pop(context);
    }).catchError((e) {
      showPlatformDialog(context: context, builder: (context) => PlatformAlertDialog(title: Text("ERROR"), content: Text("Operation Failed, Please try again later.")));
    });
  }
}
