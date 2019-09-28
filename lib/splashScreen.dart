import 'package:flutter/material.dart';
import 'package:bevvymobile/globals.dart';

//Initial Screen
class SplashScreen extends StatefulWidget
{
  const SplashScreen({ Key key, }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
{

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      body: Padding
      (
        padding: EdgeInsets.all(12),
        child: Column
        (
          children: <Widget>
          [
            Expanded
            (
              child: Image
              (
                image: AssetImage(
                    'images/icon.jpg',
                    ),
              )
            ),
            TextField
            (
              autofocus: true,
              controller: _controller,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 5)
                ),
                labelText: 'Email Address',
              ),
              onSubmitted: (v) => onSubmit(),
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
                  child: Text("Login in or signup"),
                ),
              ),
              onPressed: () => onSubmit(),
            )
          ],
        )
      )
    );
  }

  onSubmit()
  {
    auth.fetchSignInMethodsForEmail(email: _controller.text).then((List<String> results)
    {
      //If their is an email/password account
      if (results.where((String x) => x == "password").length > 0)
      {
        Navigator.pushNamed(context, "/login", arguments: _controller.text);
      }
      else
      {
        Navigator.pushNamed(context, "/createAccount", arguments: _controller.text);
      }
    });
  }
}