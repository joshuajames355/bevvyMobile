import 'package:firebase_auth/firebase_auth.dart';


class ProviderData
{
  ProviderData.FromFirebaseUser(FirebaseUser user)
  {
    user.providerData.forEach((UserInfo userInfo)
    {
      if(userInfo.providerId == "google.com") usesGoogle = true;
      if(userInfo.providerId == "password") usesPassword = true;
    });
  }

  bool usesGoogle;
  bool usesPassword;
}