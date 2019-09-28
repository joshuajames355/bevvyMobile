import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bevvymobile/globals.dart';

//Initial Screen
class CreateAccount extends StatefulWidget
{
  const CreateAccount({ Key key, this.email}) : super(key: key);

  final String email;

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount>
{

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController;

  FocusNode _lastNode = FocusNode();
  FocusNode _passwordNode = FocusNode();
  FocusNode _emailNode = FocusNode();

  DateTime _dateOfBirth;

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
        title: Text("Sign Up"),
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
                      autofocus: true,
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 5)
                        ),
                        labelText: 'First Name',
                      ),
                      onSubmitted: (v) => _lastNode.requestFocus(),
                    ),
                  ),
                  Padding
                  (
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: TextField
                    (
                      focusNode: _lastNode,
                      controller: _lastController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 5)
                        ),
                        labelText: 'Last Name',
                      ),
                      onSubmitted: (v) => _emailNode.requestFocus(),
                    ),
                  ),
                  Padding
                  (
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: TextField
                    (
                      focusNode: _emailNode,
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 5)
                        ),
                        labelText: 'Email',
                      ),
                      onSubmitted: (v) => onDateSubmit(),
                    ),
                  ),
                  FlatButton
                  (
                    child: Row
                    (
                      children: 
                      [
                        Text("Date of birth: " + (_dateOfBirth == null ? "" : formatDOB()))
                      ]
                    ),
                    onPressed: () => onDateSubmit(),
                  ),
                  Padding
                  (
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: TextField
                    (
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
                      onSubmitted: (v) => onDateSubmit(),
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
                  child: Text("Create Account"),
                ),
              ),
              onPressed: () => onSubmit(),
            )
          ]
        )
      )
    );
  }

  String formatDOB()
  {
    return _dateOfBirth.day.toString().padLeft(2, "0") + "/" + _dateOfBirth.month.toString().padLeft(2, "0") + "/" + _dateOfBirth.year.toString();
  }

  onDateSubmit()
  {
    showDatePicker(context: context, initialDate: _dateOfBirth == null ? DateTime.now() : _dateOfBirth, firstDate: DateTime(1900), lastDate: DateTime.now()).then((DateTime value)
    {
      if(value != null)
      {
        setState(() {
          _dateOfBirth=value;
        });
      }
      _passwordNode.requestFocus();
    });
  }

  onSubmit()
  {
    if(_firstNameController.text == "")
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("You must enter you first name.")));
      return;
    }
    if(_lastController.text == "")
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("You must enter you last name.")));
      return;
    }

    if(_dateOfBirth == null)
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Date of birth not selected.")));
      return;
    }

    var currentDatetime = DateTime.now();
    if(currentDatetime.year - _dateOfBirth.year < 18
      || (currentDatetime.year - _dateOfBirth.year == 18 && currentDatetime.month < _dateOfBirth.month)
      ||  (currentDatetime.year - _dateOfBirth.year == 18 && currentDatetime.month == _dateOfBirth.month && currentDatetime.day < _dateOfBirth.day) )
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("You need to be older than 18.")));
      return;
    }

    auth.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text).then((AuthResult result)
    {
      final dateOfBirth = _dateOfBirth;
      final firstName = _firstNameController.text;
      final lastName = _lastController.text;

      //Todo create user account.
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