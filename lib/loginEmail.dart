import 'package:flutter/material.dart';
import 'package:bevvymobile/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

typedef void OnLogin(FirebaseUser user);

class LoginEmailPage extends StatefulWidget {
  LoginEmailPage({Key key, this.onLogin}) : super(key: key);

  final OnLogin onLogin;

  @override
  _LoginEmailPageState createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _passwordFocus = FocusNode();
  var _obscureText = true;

   @override 
  Widget build(BuildContext context)
  {
    return SimpleDialog(
      title: Center(child: Text("Login or Signup")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
      ),      
      children: dialogContent(context),
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
      TextField
      (
        controller: _passwordTextController,
        focusNode: _passwordFocus,
        textInputAction: TextInputAction.send,
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
        onSubmitted: (v)
        {
          FocusScope.of(context).requestFocus(_passwordFocus);
        },
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
              child: Padding
              (
                child: Text("Sign In"),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: ()
              {
                if(_emailTextController.text == "" || _passwordTextController.text == "" || _emailTextController.text == null || _passwordTextController.text == null) return;

                auth.signInWithEmailAndPassword(email: _emailTextController.text, password: _passwordTextController.text).then((AuthResult result)
                {
                  widget.onLogin(result.user);
                }).catchError((e)
                {
                  if(e.code == "ERROR_USER_NOT_FOUND")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("User not found.")));
                  }
                  else if(e.code == "ERROR_WRONG_PASSWORD")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Wrong password.")));
                  }
                  else if(e.code == "ERROR_INVALID_EMAIL")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("The Email address is invalid.")));
                  }
                  else if(e.code == "ERROR_TOO_MANY_REQUESTS ")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Too many request.\n Try again later.")));
                  }
                  else if(e.code == "ERROR_USER_DISABLED")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("This account has been disabled.")));
                  }
                });           
              },
            ),
          ),
          Expanded
          (
            child: RaisedButton
            (
              child: Padding
              (
                child: Text("Create Account"),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: ()
              {
                if(_emailTextController.text == "" || _passwordTextController.text == "" || _emailTextController.text == null || _passwordTextController.text == null) return;

                auth.createUserWithEmailAndPassword(email: _emailTextController.text, password: _passwordTextController.text).then((AuthResult result)
                {
                  result.user.sendEmailVerification();
                  widget.onLogin(result.user);
                }).catchError((e)
                {
                  print(e.code);
                  if(e.code == "ERROR_EMAIL_ALREADY_IN_USE")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Email Already in Use.")));
                  }
                  else if(e.code == "ERROR_WEAK_PASSWORD")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Password too weak.\nIt must be at least 6 characters.")));
                  }
                  else if(e.code == "ERROR_INVALID_EMAIL")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("The Email address is invalid.")));
                  }
                });                
              },
            ),
          ),
        ],
      )
    ];
  }

    @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

}

