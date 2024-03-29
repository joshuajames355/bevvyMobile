import 'package:bevvymobile/dataStore.dart';
import 'package:flutter/material.dart';
import "package:bevvymobile/product.dart";
import "dart:math";

typedef void AddToBasketFunc(Product product, int quantity);

class ProductScreen extends StatefulWidget
{
  const ProductScreen({ Key key, this.product, this.addToBasket, this.dataStore}) : super(key: key);

  final Product product;
  final AddToBasketFunc addToBasket;
  final DataStore dataStore;

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin{
  ScrollController _controller = ScrollController();
  double scrollValue = 0;
  double appBarOpacity = 0;
  bool isAppBarVisible = false;

  AnimationController animationController;
  Animation<double> appBarAnimation;


  @override
  void initState() {
    animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    appBarAnimation = Tween<double>(begin: 0, end: 1).animate
    (
      CurvedAnimation
      (
        parent: animationController, 
        curve: Curves.easeInOutSine,
      )
    );
    appBarAnimation.addListener((){
      setState((){
        appBarOpacity = appBarAnimation.value;
      });
    });

    _controller.addListener((){
      if(_controller.hasClients) 
      {
        setState(() {
          scrollValue = _controller.offset;
        });
        if(isAppBarVisible && MediaQuery.of(context).size.width - _controller.offset > 100 ) 
        {
          isAppBarVisible = false;
          animationController.reverse();
        }
        if(!isAppBarVisible && MediaQuery.of(context).size.width - _controller.offset < 80)
        {
          isAppBarVisible = true;
          animationController.forward();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int quantity = 0;
    widget.dataStore.checkoutData.forEach((Product prod, int value)
    {
      if(prod.id == widget.product.id) quantity = value;
    });
    return Scaffold(
      floatingActionButton: RaisedButton
        (
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(8.0)),
        onPressed: () => widget.addToBasket(widget.product,1),
        child: Padding
        (
          padding: EdgeInsets.all(7),
          child: Text("Add to Basket" + (quantity == 0 ? "" : (" (" + quantity.toString() + ")"))),
        ),
      ),
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar
          (
            flexibleSpace: Stack(
              children:
              [
                ClipRect(
                  child: OverflowBox(
                    maxHeight: MediaQuery.of(context).size.height,
                      child: productImage(widget.product, context) 
                    ),
                ),
                Opacity(
                  opacity: min(1, max(0, appBarOpacity ?? 0)),
                  child: AppBar(
                    title: Text(widget.product.title),
                    leading: FlatButton
                    (
                      child: Icon(IconData(58820, fontFamily: 'MaterialIcons')),
                      onPressed: ()
                      {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
              ]
            ),
            expandedHeight: MediaQuery.of(context).size.width,
            pinned: true,
            floating: true,
          ),
          SliverList
          (
            delegate: SliverChildListDelegate.fixed(
              [
                Padding(
                  padding: EdgeInsets.fromLTRB(12,12,12,0),
                  child: Text(widget.product.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: "opificio"), textAlign: TextAlign.left,),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12,12,12,0),
                  child: Row
                  (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: 
                    [
                      Text(widget.product.category, style: TextStyle(fontSize: 18),),
                      Text(widget.product.size, style: TextStyle(fontSize: 18),),
                      Text(widget.product.priceString, style: TextStyle(fontSize: 18),),
                    ]
                  ),
                ),
                Divider(height: 20, thickness: 2,),
                Padding(
                  child: Text(widget.product.description, style: TextStyle(fontWeight: FontWeight.w300),),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                Container(height: 75,)
              ]
            )
          )
        ]
      )
    );
  }

  Widget productImage(Product product, BuildContext context)
  {
    return Container
    (
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.width), //maintain aspect ratio of 1
      child: SizedBox
      (
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: FittedBox
        (
          child: product.iconLarge,
          fit: BoxFit.fill,
        ),
      ),     
    );
  }
}

String getAgeRestrictionMessage(Product product)
{
  if(product.legalRestriction == "alcohol")
  {
    return "18+";
  }
  else
  {
    return "";
  }
}

