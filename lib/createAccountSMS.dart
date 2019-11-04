import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:bevvymobile/globals.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

//Initial Screen
class CreateAccountSMS extends StatefulWidget {
  const CreateAccountSMS({ Key key}) : super(key: key);

  @override
  _CreateAccountSMSState createState() => _CreateAccountSMSState();
}

class _CreateAccountSMSState extends State<CreateAccountSMS> {

  TextEditingController _noTextController = TextEditingController();

  bool _isTextSent = false;
  bool _isNumberValid = false;
  String _verificationCode = "";
  String _phoneNumber = "";
  String _phoneNumberValidated = "";
  int _resendCode = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String message = _isTextSent ? "We've sent a verification code to " + _phoneNumber : "We need to send a verification code to your phone number.";
    String textFieldLabel = _isTextSent ? "Your code" : "Phone Number";
    String buttonLabel = _isTextSent ? "Verify" : "Send Code";

    return WillPopScope(
      onWillPop: () {
        if(_isTextSent) {
          setState(() => _isTextSent = false);
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Verify Phone number"),
          leading: FlatButton(
            child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    width: double.infinity,
                    child: Text(message, style: TextStyle(fontSize: 16),),
                  ),
                )
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 5, bottom: 12, top: 0),
                  child: TextField(
                    autofocus: true,
                    controller: _noTextController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: textFieldLabel,
                    ),
                    onSubmitted: (x) => signIn(),
                    onChanged: (x) {
                      if(!_isTextSent) {
                        setState(() {
                         _isNumberValid = validatePhoneNumber();
                        });
                      }
                    },
                  )
                ),
              ),
              _isTextSent ? Card(
                child: FlatButton(
                  child: Container(
                    child: Text("Resend"),
                    width: double.infinity,
                  ),
                  onPressed: _sendSMS,
                ),
              ) : Container(),
              Expanded(child: Container(),),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),      
                padding: EdgeInsets.all(12),
                color: Theme.of(context).primaryColor,
                child: Container(
                  width: double.infinity,
                  child: Center(
                    child: Text(buttonLabel),
                  ),
                ),
                onPressed: _isTextSent ? verify : (_isNumberValid ? signIn : null) 
              )
            ]
          )
        )
      )
    );
  }

  validatePhoneNumber() {
    //Assuming UK numbers
    if(_noTextController.text.startsWith("07")) {
      _phoneNumberValidated = "+44" + _noTextController.text.substring(1);
    }
    else if (_noTextController.text.startsWith("7")) {
      _phoneNumberValidated = "+44" + _noTextController.text;
    }
    else if(!_noTextController.text.startsWith("+44")) {
      return false;
    }

    if(_phoneNumberValidated.length != 13) {
      return false;
    }

    List<String> validDigits = ["0","1","2","3","4","5","6","7","8","9"];
    
    for(int x =1; x < _phoneNumberValidated.length; x++) {
      if(!validDigits.contains(_phoneNumberValidated[x])) {
        return false;
      }
    }

    return true;
  }

  signIn() {
    if(!validatePhoneNumber()) {
      return;
    }

    _phoneNumber = _phoneNumberValidated;
    _noTextController.text = "";
    _sendSMS();
  }  

  _sendSMS() {
    auth.verifyPhoneNumber(phoneNumber: _phoneNumber, timeout: Duration(seconds: 30), 
      verificationCompleted: verificationCompleted,
      verificationFailed: (AuthException error) {
        showPlatformDialog(androidBarrierDismissible: true,context: context, builder: (context) => PlatformAlertDialog(actions: <Widget>[PlatformDialogAction(child: Text("Ok"), onPressed: () => Navigator.pop(context),)],title: Text("Error"), content: Text("Verification Failed.")));
        setState(() {
          _isTextSent = false;
        });
      },
      codeSent: (String verificationID, [int resendingToken]) {
        setState(() {
          _isTextSent = true;
          _verificationCode = verificationID;
          _resendCode = resendingToken;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId){},
      forceResendingToken: _resendCode,
    ).then((x) {
      setState(() {
        _isTextSent = true;
      });
    }); 
  }

  verificationCompleted(AuthCredential credential) async {
    return wrapperSignInWithCredential(credential);
  }

  verify() async {
    var credential = PhoneAuthProvider.getCredential(verificationId: _verificationCode, smsCode: _noTextController.text);
    await wrapperSignInWithCredential(credential);
  }

  wrapperSignInWithCredential(credential) async {
    try {
      AuthResult _ = await auth.signInWithCredential(credential);
    } catch(e) {
      switch (e.code) {
        case "ERROR_INVALID_CREDENTIAL":
          showPlatformDialog(androidBarrierDismissible: true,context: context, builder: (context) => PlatformAlertDialog(actions: <Widget>[PlatformDialogAction(child: Text("Ok"), onPressed: () => Navigator.pop(context),)],title: Text("Error"), content: Text("Invalid SMS Code.")));
          break;
        case "ERROR_USER_DISABLED":
          showPlatformDialog(androidBarrierDismissible: true,context: context, builder: (context) => PlatformAlertDialog(actions: <Widget>[PlatformDialogAction(child: Text("Ok"), onPressed: () => Navigator.pop(context),)],title: Text("Error"), content: Text("This account has been disabled.")));
          break;
        case "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL":
          showPlatformDialog(androidBarrierDismissible: true,context: context, builder: (context) => PlatformAlertDialog(actions: <Widget>[PlatformDialogAction(child: Text("Ok"), onPressed: () => Navigator.pop(context),)],title: Text("Error"), content: Text("Account already exists.")));
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          break;
        case "ERROR_INVALID_ACTION_CODE":
          break;
        default:
          throw new UnimplementedError(e.code);
      }
    }
  }
}
