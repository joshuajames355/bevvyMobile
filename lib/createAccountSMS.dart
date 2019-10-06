import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:bevvymobile/globals.dart';

//Initial Screen
class CreateAccountSMS extends StatefulWidget
{
  const CreateAccountSMS({ Key key, this.email}) : super(key: key);

  final String email;

  @override
  _CreateAccountSMSState createState() => _CreateAccountSMSState();
}

class _CreateAccountSMSState extends State<CreateAccountSMS>
{

  TextEditingController _noTextController = TextEditingController();
  TextEditingController _smsPin = TextEditingController();

  FocusNode _passwordNode = FocusNode();
  FocusNode _emailNode = FocusNode();

  bool _isTextSent = false;
  String _verificationCode = "";
  String _phoneNumber = "";
  int _resendCode = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    String message = _isTextSent ? "We've sent a verification code to " + _phoneNumber : "We need to send a verification code to your phone number.";
    String textFieldLabel = _isTextSent ? "Your code" : "Phone Number";
    String buttonLabel = _isTextSent ? "Verify" : "Send Code";

    return WillPopScope
    (
      onWillPop: ()
      {
        if(_isTextSent)
        {
          setState(() {
            _isTextSent = false; 
          });
        }
        else
        {
          Navigator.pop(context);
        }
      },
      child: Scaffold
      (
        appBar: AppBar
        (
          title: Text("Verify Phone number"),
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
              Card
              (
                child: Padding
                (
                  padding: EdgeInsets.all(12),
                  child: Container
                  (
                    width: double.infinity,
                    child: Text(message, style: TextStyle(fontSize: 16),),
                  ),
                )
              ),
              Card
              (
                child: Padding
                (
                  padding: EdgeInsets.only(left: 5, right: 5, bottom: 12, top: 0),
                  child: TextField
                  (
                    autofocus: false,
                    controller: _noTextController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: textFieldLabel,
                    ),
                    onSubmitted: (x) => signIn(),
                  )
                ),
              ),
              _isTextSent ? Card
              (
                child: FlatButton
                (
                  child: Container
                  (
                    child: Text("Resend"),
                    width: double.infinity,
                  ),
                  onPressed: ()
                  {
                    
                  },
                ),
              ) : Container(),
              Expanded(child: Container(),),
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
                    child: Text(buttonLabel),
                  ),
                ),
                onPressed: ()
                {
                  if(_isTextSent)
                  {
                    verify();
                  }
                  else
                  {
                    signIn();
                  }
                },
              )
            ]
          )
        )
      )
    );
  }

  signIn()
  {
    //Assuming UK numbers
    _phoneNumber = _noTextController.text;
    _noTextController.text = "";
    if(_phoneNumber.startsWith("07"))
    {
      _phoneNumber = "+44" + _phoneNumber.substring(1);
    }
    else if (_phoneNumber.startsWith("7"))
    {
      _phoneNumber = "+44" + _phoneNumber;
    }
    else if(!_phoneNumber.startsWith("+44"))
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Phone number invalid.")));
    }
    auth.verifyPhoneNumber(phoneNumber: _phoneNumber, timeout: Duration(seconds: 30), 
      verificationCompleted: verificationCompleted,
      verificationFailed: (AuthException error) 
      {
        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Verification Failed.")));
        setState(() 
        {
          _isTextSent = false;
        });
      },
      codeSent: (String verificationID, [int resendingToken])
      {
        setState(() 
        {
          _isTextSent = true;
          _verificationCode = verificationID;
          _resendCode = resendingToken;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId){}
    ).then((x)
    {
      setState(() 
      {
        _isTextSent = true;
      });
    });   
  }  

  verificationCompleted(AuthCredential credential)
  {
    auth.signInWithCredential(credential).then((AuthResult result)
    {
      Navigator.pushNamed(context, "/createAccount");
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
  }   

  verify()
  {
    var credentials = PhoneAuthProvider.getCredential(verificationId: _verificationCode, smsCode: _noTextController.text);
    auth.signInWithCredential(credentials).then((AuthResult result)
    {
      Navigator.pushNamed(context, "/createAccount");
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
  }
}