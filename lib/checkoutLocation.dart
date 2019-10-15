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
  Location location = Location();
  LocationData lastLocationFix;

  @override
  void initState() {
    getLocation();
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
      body: Stack
      (
        children: 
        [
          GoogleMap
          (
            initialCameraPosition: CameraPosition(target: lastLocationFix == null ? LatLng(54.7753, -1.5849) : LatLng(lastLocationFix.latitude, lastLocationFix.longitude), zoom: 16),
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
              child: Icon(IconData(58716, fontFamily: 'MaterialIcons',), color: Theme.of(context).accentColor, size: 50,),
            ),
          )          
        ]
      ),
      floatingActionButton: FloatingActionButton
      (
        child: Icon(IconData(58716, fontFamily: 'MaterialIcons')),
        onPressed: getLocation,
      ),
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