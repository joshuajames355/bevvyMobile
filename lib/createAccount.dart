import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:bevvymobile/globals.dart';

typedef dynamic HandleAuthStateChangeFunc(FirebaseUser updatedUser);

//Initial Screen
class CreateAccount extends StatefulWidget
{
  const CreateAccount({ Key key, this.user, this.handleAuthStateChangeFunc}) : super(key: key);

  final FirebaseUser user;
  final HandleAuthStateChangeFunc handleAuthStateChangeFunc;


  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount>
{

  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  FocusNode _surnameNode = FocusNode();
  FocusNode _emailNode = FocusNode();
  FocusNode _dobNode = FocusNode();

  DateTime _dateOfBirth;

  final Firestore store = Firestore();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    DateTime endDate = DateTime.now();
    endDate = DateTime(endDate.year - 18, endDate.month, endDate.day);
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
                  Card
                  (
                    child: Padding
                    (
                      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
                      child: TextField
                      (
                        autofocus: false,
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'First Name',
                        ),
                        onSubmitted: (x) =>  _surnameNode.requestFocus(),
                      )
                    ),
                  ),
                  Card
                  (
                    child: Padding
                    (
                      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
                      child: TextField
                      (
                        autofocus: false,
                        focusNode: _surnameNode,
                        controller: _surnameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Surname',
                        ),
                        onSubmitted: (x) =>  _emailNode.requestFocus(),
                      )
                    ),
                  ),
                  Card
                  (
                    child: Padding
                    (
                      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
                      child: TextField
                      (
                        focusNode: _emailNode,
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Email',
                        ),
                        onSubmitted: (x) =>  _dobNode.requestFocus(),
                      )
                    ),
                  ),
                  Card
                  (
                    child: Padding
                    (
                      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
                      child: DateTimeField
                      (
                        focusNode: _dobNode,
                        format: DateFormat("yyyy-MM-dd"),
                        onShowPicker: (context, currentValue) {
                          return showDatePicker
                          (
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: currentValue ?? DateTime(2000),
                              lastDate: endDate
                          ).then((DateTime x)
                          {
                            _dateOfBirth = x;
                            return x;
                          });
                        },
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Date Of Birth',
                          ),
                      ),
                    )
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
    DateTime endDate = DateTime.now();
    endDate = DateTime(endDate.year - 18, endDate.month, endDate.day);
    showDatePicker(context: context, initialDate: _dateOfBirth == null ? DateTime(2000) : _dateOfBirth, firstDate: DateTime(1900), lastDate: endDate).then((DateTime value)
    {
      if(value != null)
      {
        setState(() {
          _dateOfBirth=value;
        });
      }
    });
  }

  onSubmit()
  {
    if(_nameController.text == "")
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Full Name is required.")));
      return;
    }
    if(_emailController.text == "")
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Email Address is required.")));
      return;
    }
    if(_dateOfBirth == null)
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Date of birth is required.")));
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

    final dateOfBirth = _dateOfBirth;
    final firstName = _nameController.text;
    final surname = _surnameController.text;
    final emailAddress = _emailController.text;

    Firestore.instance.collection('users').document(widget.user.uid).updateData({
      'onboardingStatus': 'onboarded_user',
      'personalDetails': {
        'firstName': firstName,
        'lastName': surname,
        'dateOfBirth': dateOfBirth.toIso8601String().substring(0, 10),
        'emailAddress': emailAddress,
      }
    }).then((_) {
      // Fetch user data doc, this in in turn prompt navigation
      widget.handleAuthStateChangeFunc(widget.user);
    }).catchError((e) {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("ERROR"), content: Text("Creating Account Failed, Please try again later.")));
    });
  }
}