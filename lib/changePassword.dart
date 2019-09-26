import 'package:flutter/material.dart';
import 'package:bevvymobile/reauthenticate.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget
{
  const ChangePassword({ Key key, this.user}) : super(key: key);

  final FirebaseUser user;

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>
{
  TextEditingController _newPasswordController = new TextEditingController();
  var _obscureText = true;

  @override 
  Widget build(BuildContext context)
  {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
      ),      
      title: Center(child: Text("Change Password")),
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
        controller: _newPasswordController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.visiblePassword,
        obscureText: _obscureText,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 5)
          ),
          labelText: 'New Password',
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
        onSubmitted: (String x) 
        {
          changePassword();
        },       
        
      ),
      RaisedButton
      (
        child: Container
        (
          width: double.infinity,
          padding: EdgeInsets.all(12),
          child: Text("Change Password"),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: changePassword,
      )
    ];
  }

  changePassword()
  {
    widget.user.updatePassword(_newPasswordController.text).then((x)
    {
      Navigator.pop(context, true);
    }).catchError((error)
    {
      if(error.code == "ERROR_REQUIRES_RECENT_LOGIN")
      {
        reauthenticate(context, widget.user).then((x)
        {
          widget.user.updatePassword(_newPasswordController.text).then((x)
          {
            Navigator.pop(context,true);
          }).catchError((error)
          {
            if(error.code == "ERROR_REQUIRES_RECENT_LOGIN")
            {
              showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Reauthentication Failed.")));
            }
            else if(error.code == "ERROR_WEAK_PASSWORD")
            {
              showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Password too weak.")));
            }
            else
            {
              showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text(error.code)));
            }
          });
        });
      }
      else if(error.code == "ERROR_WEAK_PASSWORD")
      {
        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text("Password too weak.")));
      }
      else
      {
        showDialog(context: context, builder: (context) => AlertDialog(title: Text("Error"), content: Text(error.code)));
      }
    });
  }
}
