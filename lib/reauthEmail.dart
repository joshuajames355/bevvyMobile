import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ReauthEmailPage extends StatefulWidget {
  ReauthEmailPage({Key key}) : super(key: key);

  @override
  _ReauthEmailPageState createState() => _ReauthEmailPageState();
}

class _ReauthEmailPageState extends State<ReauthEmailPage> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _passwordFocus = FocusNode();
  var _obscureText = true;

  @override 
  Widget build(BuildContext context)
  {
    return SimpleDialog(
      title: Center(child: Text("Re-enter password.")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
      ),      
      children: dialogContent(context),
      contentPadding: EdgeInsets.all(7),
    );
  }

  List<Widget> dialogContent(BuildContext context)
  {
    IconData visibilityIcon = _obscureText ? IconData(59636, fontFamily: 'MaterialIcons') : IconData(59637, fontFamily: 'MaterialIcons');
    return
    [
      TextField
      (
        autofocus: true,
        controller: _emailTextController,
        textInputAction: TextInputAction.next,
         keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 5)
          ),
          labelText: 'Email',
        ),
        onSubmitted: (v)
        {
          FocusScope.of(context).requestFocus(_passwordFocus);
        },
      ),
      Container
      (
        margin: EdgeInsets.only(bottom: 10),
        child: TextField
        (
          controller: _passwordTextController,
          focusNode: _passwordFocus,
          textInputAction: TextInputAction.go,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'Password',
            suffixIcon: FlatButton(
              child: Icon(visibilityIcon),
              onPressed: ()
              {
                setState(() 
                {
                  _obscureText = !_obscureText;
                });
              },
            )
          ),
          obscureText: _obscureText,
          onSubmitted: (String password)
          {
            signIn();
          },
        ),
      ),
      Row
      (
        mainAxisSize: MainAxisSize.max,
        children: <Widget>
        [
          Expanded
          (
            child: RaisedButton
            (
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(10))),
              color: Theme.of(context).primaryColor,
              child: Padding
              (
                child: Text("Sign In"),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: signIn,
            ),
          )
        ],
      )
    ];
  }

  signIn()
  {
    if(_emailTextController.text == "" || _passwordTextController.text == "" || _emailTextController.text == null || _passwordTextController.text == null) 
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("The email and password fields must not be empty.")));
      return;
    }
    Navigator.pop(context, EmailAuthProvider.getCredential(email: _emailTextController.text, password: _passwordTextController.text));
  }

  @override
  void dispose() 
  {
    // Clean up the controller when the widget is disposed.
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }
}