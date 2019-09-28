import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bevvymobile/globals.dart';

//Initial Screen
class LoginPage extends StatefulWidget
{
  const LoginPage({ Key key, this.email}) : super(key: key);

  final String email;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController;

  FocusNode _passwordNode = FocusNode();

  var _obscureText = true;

  @override
  void initState() {
    _emailController = TextEditingController(text: widget.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    IconData visibilityIcon = _obscureText ? IconData(59636, fontFamily: 'MaterialIcons') : IconData(59637, fontFamily: 'MaterialIcons');
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text("Sign In"),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding
      (
        padding: EdgeInsets.all(12),
        child: Column
        (
          children: 
          [
            Expanded(
              child: ListView
              (
                children: <Widget>
                [
                  Padding
                  (
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: TextField
                    (
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 5)
                        ),
                        labelText: 'Email',
                      ),
                      onSubmitted: (v) => _passwordNode.requestFocus(),
                    ),
                  ),
                  Padding
                  (
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: TextField
                    (
                      autofocus: true,
                      focusNode: _passwordNode,
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      obscureText: _obscureText,
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
                      onSubmitted: (v) => onSubmit(),
                    ),
                  ),
                ],
              )
            ),
            RaisedButton
            (
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),      
              padding: EdgeInsets.all(12),
              color: Theme.of(context).primaryColor,
              child: Container
              (
                width: double.infinity,
                child: Center
                (
                  child: Text("Sign In"),
                ),
              ),
              onPressed: () => onSubmit(),
            )
          ]
        )
      )
    );
  }

  onSubmit()
  {
    if(_emailController.text == "" || _passwordController.text == "" || _emailController.text == null || _passwordController.text == null) 
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("The email and password fields must not be empty.")));
      return;
    }

    auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text).then((AuthResult result)
    {
      print("Login");
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
      else if(e.code == "ERROR_TOO_MANY_REQUESTS")
      {
        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Too many request.\n Try again later.")));
      }
      else if(e.code == "ERROR_USER_DISABLED")
      {
        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("This account has been disabled.")));
      }
    });         
  }
}