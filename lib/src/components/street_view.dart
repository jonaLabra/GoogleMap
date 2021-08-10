import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

class StreetView extends MethodChannelStreetViewFlutter {
  final double lat, lng;
  // ignore: sort_constructors_first
  StreetView({@required this.lat, @required this.lng});
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          FlutterGoogleStreetView(
            initPos: LatLng(37.769263, -122.450727),
            //initPanoId: "WddsUw1geEoAAAQIt9RnsQ",
            initSource: StreetViewSource.def,
            initBearing: 10,
            initTilt: 10,
            initZoom: 0,
            //panningGesturesEnabled: false,
            //streetNamesEnabled: false,
            //userNavigationEnabled: false,
            //zoomGesturesEnabled: false,
            onStreetViewCreated: (controller) async {
              await controller.animateTo(
                  duration: 50,
                  camera:
                      StreetViewPanoramaCamera(bearing: 15, tilt: 10, zoom: 0));
            },
          ),
        ],
      ),
    );
  }
}
