import 'package:flutter/material.dart';
import 'package:bevvymobile/globals.dart';

//Initial Screen
class SplashScreen extends StatefulWidget
{
  const SplashScreen({ Key key, }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin
{

  TextEditingController _controller = TextEditingController();
  List<Widget> images = [
    SplashScreenImage(desription: "Description 1. Our company is called Jovi, maybe we should do something.", imageFilename: "images/smirnoff.jpg",),
    SplashScreenImage(desription: "Description 2", imageFilename: "images/jd.jpg",)
    ];
  AnimationController animationController;
  Animation<double> imageAnimation;

  AnimationController introAnimationController;
  Animation<double> introAnimation;

  int currentImage = 0;
  double position = 0;
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    imageAnimation = Tween<double>(begin: 400, end: 0).animate
    (
      CurvedAnimation
      (
        parent: animationController, 
        curve: Curves.easeInOutSine,
      )
    );

    imageAnimation.addStatusListener((AnimationStatus state)
    {
      if(state == AnimationStatus.completed)
      {
        Future.delayed(Duration(seconds: 4)).then((x)
        {
          animationController.reverse();
        });
      }
      if(state == AnimationStatus.dismissed)
      {
        setState(()
        {
          currentImage = (currentImage + 1) % images.length;
        });
        animationController.forward();
      }
    });

    imageAnimation.addListener(()
    {
      setState(() 
      {
        position = imageAnimation.value;
        opacity = 1;
      });
    });

    introAnimationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    introAnimation = Tween<double>(begin: 600, end: 0).animate
    (
      CurvedAnimation
      (
        parent: introAnimationController, 
        curve: Curves.easeIn,
      )
    );
    introAnimation.addListener(()
    {
      setState(() {});
    });
    introAnimationController.forward().then((x)
    {
      animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context)
  {
    
    return Scaffold
    (
      appBar: AppBar
      (
        backgroundColor: Theme.of(context).primaryColorLight,
        title: Center
        (
          child: Text("Jovi", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold))
        ),
      ),
      body: Padding
      (
        padding: EdgeInsets.all(12),
        child: Column
        (
          children: <Widget>
          [
            Flexible
            (
              child: Transform.translate
              (
                child: Opacity
                (
                  opacity: opacity,
                  child: images[currentImage]
                ),
                offset: Offset(position,0),
              ),
              fit: FlexFit.loose
            ),
            Divider(),
            Flexible
            (
              fit: FlexFit.loose,
              child: Transform.translate
              (
                offset: Offset(0, introAnimation.value),
                child: Column
                (
                  children: <Widget>
                  [
                    TextField
                    (
                      autofocus: false,
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        // borderSide: BorderSide(color: Colors.white, width: 5)
                        labelText: 'Email Address',
                      ),
                      onSubmitted: (v) => onSubmit(),
                    ),
                    Padding
                    (
                      padding: EdgeInsets.only(top: 8),
                      child: RaisedButton
                      (
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MediaQuery.of(context).viewInsets.bottom==0.0 ? 
              Expanded
              (
                child: Container(),
              ) :
              Container(),
            MediaQuery.of(context).viewInsets.bottom==0.0 ? 
              Text("Some boring legal stuff. Will probably fill this is later with something more usefull, but until then we have this random stream of conscionness where lorem ipsum would have probably been more appropriate.",
                  style: TextStyle(fontSize: 8),) :
                Container(),
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

  @override
  void dispose()
  {
    animationController.dispose();
    introAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class SplashScreenImage extends StatelessWidget
{
  const SplashScreenImage({ Key key, this.imageFilename, this.desription}) : super(key: key);

  final String imageFilename;
  final String desription;


  @override
  Widget build(BuildContext context)
  {
    return Container
    (
      child: Card
      (
        child: Padding
        (
          padding: EdgeInsets.all(12),
          child: Column
          (
            children: 
            [ 
              Flexible
              (
                child: Image
                (
                  height: 200,
                  width: 200,
                  image: AssetImage(imageFilename),
                ),
                fit: FlexFit.loose,
              ),
              Padding
              (
                child: Text(desription),
                padding: EdgeInsets.all(3),
              )
            ]
          )
        )
      )
    );
  }
}