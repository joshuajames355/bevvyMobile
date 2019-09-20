import 'package:flutter/material.dart';
import 'package:bevvymobile/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:bevvymobile/loginEmail.dart';


class LoginPhonePage extends StatefulWidget {
  LoginPhonePage({Key key, this.onLogin}) : super(key: key);

  final OnLogin onLogin;

  @override
  _LoginPhonePageState createState() => _LoginPhonePageState();
}

class _LoginPhonePageState extends State<LoginPhonePage> {
  final _noTextController = TextEditingController();
  final _smsCodeTextController = TextEditingController();
  bool _isTextSent = false;
  String _verificationCode;

   @override 
  Widget build(BuildContext context)
  {
    return SimpleDialog(
      title: Center(child: Text("Login or Signup")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
      ),      
      children: dialogContent(context),
      contentPadding: EdgeInsets.all(7),
    );
  }

  List<Widget> dialogContent(BuildContext context)
  {
    if(!_isTextSent)
    {
      return sendSmsWidget(context);
    }
    else
    {
      return verifyCodeUI(context);
    }
  }

  List<Widget> sendSmsWidget(BuildContext context)
  {
    return
    [
      Container
      (
        margin: EdgeInsets.symmetric(vertical: 10),
        child: TextField
        (
          autofocus: true,
          controller: _noTextController,
          textInputAction: TextInputAction.send,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'Phone Number',
          ),
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
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(6))),
              child: Padding
              (
                child: Text("Sign In"),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: ()
              {
                //Assuming UK numbers
                var number = _noTextController.text;
                if(number.startsWith("07"))
                {
                  number = "+44" + number.substring(1);
                }
                else if (number.startsWith("7"))
                {
                  number = "+44" + number;
                }
                else if(!number.startsWith("+44"))
                {
                  print("Number not recognized: " + number);
                }
                auth.verifyPhoneNumber(phoneNumber: number, timeout: Duration(seconds: 120), 
                verificationCompleted: (AuthCredential credential)
                {
                  auth.signInWithCredential(credential).then((AuthResult result)
                  {
                    widget.onLogin(result.user);
                  }).catchError((e)
                  {
                    if(e.code == "ERROR_INVALID_CREDENTIAL")
                    {
                      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Invalid SMS Code.")));
                    }
                    else if(e.code == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL")
                    {
                      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Account already exists.")));
                    }
                    else if(e.code == "ERROR_USER_DISABLED")
                    {
                      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("This account has been disabled.")));
                    }
                  });
                },
                verificationFailed: (AuthException error)
                {

                },
                codeSent: (String verificationID, [int resendingToken])
                {
                  setState(() 
                  {
                    _isTextSent = true;
                    _verificationCode = verificationID;
                  });
                },
                codeAutoRetrievalTimeout: (String verificationId)
                {

                });
          
              },
            ),
          ),
        ],
      )
    ];
  }

  List<Widget> verifyCodeUI(BuildContext context)
  {
    return [
      Container
      (
        margin: EdgeInsets.symmetric(vertical: 10),
        child: TextField
        (
          autofocus: true,
          controller: _smsCodeTextController,
          textInputAction: TextInputAction.send,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'SMS Code',
          ),
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
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(6))),
              color: Theme.of(context).primaryColor,
              child: Padding
              (
                child: Text("Back"),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: ()
              {
                setState(() 
                {
                  _isTextSent = false;
                });
              },
            ),
          ),
          Expanded
          (
            child: RaisedButton
            (
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(6))),
              color: Theme.of(context).primaryColor,
              child: Padding
              (
                child: Text("Resend"),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: ()
              {
                
              },
            ),
          ),
          Expanded
          (
            child: RaisedButton
            (
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(6))),
              color: Theme.of(context).primaryColor,
              child: Padding
              (
                child: Text("Verify"),
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: ()
              {
                var credentials = PhoneAuthProvider.getCredential(verificationId: _verificationCode, smsCode: _smsCodeTextController.text);
                auth.signInWithCredential(credentials).then((AuthResult result)
                {
                  widget.onLogin(result.user);
                }).catchError((e)
                {
                  if(e.code == "ERROR_INVALID_CREDENTIAL")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Invalid SMS Code.")));
                  }
                  else if(e.code == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Account already exists.")));
                  }
                  else if(e.code == "ERROR_USER_DISABLED")
                  {
                    showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("This account has been disabled.")));
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
    _noTextController.dispose();
    _smsCodeTextController.dispose();
    super.dispose();
  }
}