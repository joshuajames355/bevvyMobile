import 'package:flutter/material.dart';

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
    SplashScreenImage(description: "Description 1. Our company is called Jovi, maybe we should do something.", imageFilename: "images/smirnoff.jpg",),
    SplashScreenImage(description: "Description 2", imageFilename: "images/jd.jpg",)
    ];
  AnimationController animationController;
  Animation<double> imageAnimation;

  AnimationController introAnimationController;
  Animation<double> introAnimationContinueButton;
  Animation<double> introAnimationLogo;

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

    introAnimationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    introAnimationLogo = Tween<double>(begin: -500, end: 0).animate
    (
      CurvedAnimation
      (
        parent: introAnimationController, 
        curve: Interval
        (
          0,
          0.8,
          curve: Curves.easeIn,
        )
      )
    );
    introAnimationContinueButton = Tween<double>(begin: 600, end: 0).animate
    (
      CurvedAnimation
      (
        parent: introAnimationController, 
        curve: Interval
        (
          0.5,
          1,
          curve: Curves.easeIn,
        )
      )
    );
    introAnimationContinueButton.addListener(()
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
      body: Padding
      (
        padding: EdgeInsets.all(12),
        child: Column
        (
          children: <Widget>
          [
            Flexible
            (
              fit: FlexFit.loose,
              flex: 1,
              child: Transform.translate
              (
                offset: Offset(introAnimationLogo.value, 0),
                child: Image
                (
                  height: 200,
                  width: 200,
                  image: AssetImage
                  (
                    'images/logo.png',
                  ),
                ),
              ),
            ),
            Divider
            (
              height: 12,
            ),
            Container
            (
              height: 24,
            ),
            Transform.translate
            (
              child: Opacity
              (
                opacity: opacity,
                child: images[currentImage]
              ),
              offset: Offset(position,0),
            ),    
            Expanded(child: Container(),),
            Transform.translate
            (
              offset: Offset(0, introAnimationContinueButton.value),
              child: Padding
              (
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Column
                (
                  children:
                  [
                    RaisedButton
                    (
                      padding: EdgeInsets.all(14),
                      color: Theme.of(context).primaryColor,
                      child: Container
                      (
                        width: double.infinity,
                        child: Center
                        (
                          child: Text("Continue"),
                        ),
                      ),
                      onPressed: () => onSubmit(),
                    ),
                    Padding
                    (
                      padding: EdgeInsets.only(top: 12),
                      child: Text("Some boring legal stuff. Will probably fill this is later with something more usefull, but until then we have this random stream of conscionness where lorem ipsum would have probably been more appropriate.",
                        style: TextStyle(fontSize: 8),) 
                    ),
                  ]
                ),
              ),                           
            ),              
          ],
        )
      )
    );
  }

  onSubmit()
  {
    Navigator.pushNamed(context, "/createAccountSMS", arguments: _controller.text);
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
  const SplashScreenImage({ Key key, this.imageFilename, this.description}) : super(key: key);

  final String imageFilename;
  final String description;


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
              Image
              (
                height: 200,
                width: 200,
                image: AssetImage(imageFilename),
              ),
              Padding
              (
                child: Text(description),
                padding: EdgeInsets.all(3),
              )
            ]
          )
        )
      )
    );
  }
}