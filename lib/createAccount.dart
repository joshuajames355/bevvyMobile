import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bevvymobile/globals.dart';
import 'package:intl/intl.dart';

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
  TextEditingController _dobController = TextEditingController();

  FocusNode _surnameNode = FocusNode();
  FocusNode _emailNode = FocusNode();
  FocusNode _dobNode = FocusNode();

  DateTime _dateOfBirth;

  final Firestore store = Firestore();

  @override
  void initState() {
    _dobNode.addListener(() => onDateSubmit(context));

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
            auth.signOut();
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
                        textCapitalization: TextCapitalization.words,
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
                        textCapitalization: TextCapitalization.words,
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
                        autocorrect: false,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Email',
                        ),
                        onSubmitted: (x) =>  onDateSubmit(context),
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
                        focusNode: _dobNode,
                        controller: _dobController,
                        readOnly: true,
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

  onDateSubmit(BuildContext context)
  {
    //hide keyboard
    FocusScope.of(context).unfocus();

    DateTime endDate = DateTime.now();
    endDate = DateTime(endDate.year - 18, endDate.month, endDate.day);
    showModalBottomSheet
    (
      context: context,
      builder: (BuildContext builder) 
      {
        return Container
        (
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: Theme
          (
            data: Theme.of(context).copyWith(brightness: Brightness.light),
            child:CupertinoDatePicker
            (
              
              initialDateTime: _dateOfBirth ?? DateTime(2000),
              onDateTimeChanged: (DateTime newdate) 
              {
                setState(() {
                  _dateOfBirth = newdate;
                  _dobController.text = DateFormat("yyyy-MM-dd").format(newdate);
                });
              },
              maximumDate: endDate,
              minimumYear: 1900,
              maximumYear: endDate.year,
              mode: CupertinoDatePickerMode.date,
            )  
          )                    
        );
      }
    );          
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