import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bevvymobile/reauthEmail.dart';

Future<void> reauthenticate(BuildContext context ,FirebaseUser user) async
{
  bool hasEmail = false;
  user.providerData.forEach((UserInfo userInfo)
  {
    if(userInfo.providerId == "password") hasEmail = true;
  });

  AuthCredential credentials;

  if(hasEmail)
  {
    credentials = await showDialog(context: context, builder: (BuildContext context) => ReauthEmailPage());
  }
  else
  {
    print("Reauth failed, no recongnized provider");
    return;
  }

  try
  {
    await user.reauthenticateWithCredential(credentials);
  }
  //Some weird error in firebase auth ^0.14.0+5
  on NoSuchMethodError catch(e)
  {
    print("NoSuchMethodError");
    return;
  }
  catch (e)
  {
    print("REAUTH FAIL");
    print(e);
    print(e.code);
    if(e.code == "ERROR_INVALID_CREDENTIAL")
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("ERROR"), content: Text("Invalid Credentials")));
    }
    else
    {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("ERROR"), content: Text(e.code)));
    }
  }
}