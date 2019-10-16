import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CheckoutLocation extends StatefulWidget
{
  const CheckoutLocation({ Key key}) : super(key: key);

  @override
  _CheckoutLocationState createState() => _CheckoutLocationState();
}

class _CheckoutLocationState extends State<CheckoutLocation>
{
  GoogleMapController _googleController;

  //GPS location
  Location location = Location();
  LocationData lastLocationFix;

  CameraPosition cameraPosition; 

  @override
  void initState() {
    getLocation();
    cameraPosition = CameraPosition(target: lastLocationFix == null ? LatLng(54.7753, -1.5849) : LatLng(lastLocationFix.latitude, lastLocationFix.longitude), zoom: 16);
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Center(child: Text("Select Location")),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons', matchTextDirection: true)),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column
      (
        children: 
        [
          Expanded
          (
            child: Stack
            (
              children: 
              [
                GoogleMap
                (
                  initialCameraPosition: cameraPosition,
                  onCameraMove: (CameraPosition position)
                  {
                    cameraPosition = position;
                  },
                  onMapCreated: (GoogleMapController controller)
                  {
                    _googleController = controller;
                    if(lastLocationFix != null)
                    {
                      _googleController.animateCamera(CameraUpdate.newLatLng(LatLng(lastLocationFix.latitude, lastLocationFix.longitude)));
                    }
                  },
                ),
                Positioned.fill
                (
                  child: Align
                  (
                    alignment: Alignment.center,
                    child: Transform.translate
                    (
                      offset: Offset(0, -25),
                      child: Icon(IconData(57544, fontFamily: 'MaterialIcons',), color: Theme.of(context).accentColor, size: 50,),
                    )
                  ),
                )          
              ]
            ),
          ),
          RaisedButton
          (
            child:  Container
            (
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Center
              (
                child: Text("Confirm Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ),
              width: double.infinity,
            ),
            onPressed: ()
            {
              Navigator.pushNamed(context, "/checkout", arguments: cameraPosition.target);
            },
          )
        ]
      ),
      floatingActionButton: Padding
      (
        padding: EdgeInsets.only(bottom: 50),
        child: FloatingActionButton
        (
          child: Icon(IconData(58716, fontFamily: 'MaterialIcons')),
          onPressed: getLocation,
        ),
      )
    );
  }

  getLocation()
  {
    location.getLocation().then((LocationData data)
    {
      if(_googleController != null)
      {
        _googleController.animateCamera(CameraUpdate.newLatLng(LatLng(data.latitude, data.longitude)));
      }
      lastLocationFix = data;
    }).catchError((e)
    {
      print(e);

    });
  }
}