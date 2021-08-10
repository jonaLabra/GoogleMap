import 'dart:async';
import 'dart:typed_data';

import 'package:example/src/components/street_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:screenshot/screenshot.dart';

// ignore: camel_case_types
class Maps_Data extends ChangeNotifier {
  TextEditingController destinationController = TextEditingController();
  List<double> positions = [0.0, 0.0];
  final geocoding =
      GoogleMapsGeocoding(apiKey: 'AIzaSyCUUWOZTunTAP8AHftO6u6uP3sntmyz0ZQ');
  final Set<Marker> markers = {};
  LatLng _lastP;
  InAppWebViewController controller;
  ScreenshotController controllerS;

  Future<List<double>> getUserLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    positions = [position.latitude, position.longitude];
    return positions;
  }

  /*Future<List<double>> displayPrediction(String p) async {
    // ignore: unnecessary_null_comparison
    if (p != null) {
      var response = await geocoding.searchByAddress(p);
      response.results.forEach((element) {
        _latitude = element.geometry.location.lat;
        _longitude = element.geometry.location.lng;
      });
      cordinates = [_latitude, _longitude];
      return cordinates;
    } else {
      return cordinates;
    }
  }*/

  void _addMarker(LatLng location, String address) {
    markers.clear();
    markers.add(Marker(
        markerId: MarkerId(_lastP.toString()),
        position: location,
        infoWindow: InfoWindow(title: address),
        icon: BitmapDescriptor.defaultMarker));
  }

  // ignore: always_declare_return_types
  sendRequest(Prediction p, context, key,
      Completer<GoogleMapController> _controller) async {
    // ignore: omit_local_variable_types
    GoogleMapController _mapController = await _controller.future;
    try {
      // ignore: unnecessary_null_comparison
      if (p != null) {
        // ignore: omit_local_variable_types
        GoogleMapsPlaces _places = GoogleMapsPlaces(
            apiKey: 'AIzaSyCUUWOZTunTAP8AHftO6u6uP3sntmyz0ZQ',
            apiHeaders: await GoogleApiHeaders().getHeaders());
        // ignore: omit_local_variable_types
        PlacesDetailsResponse detail =
            await _places.getDetailsByPlaceId(p.placeId);
        // ignore: avoid_print
        print(
            'Direccion ${p.description} \n Lat: ${detail.result.geometry.location.lat} \n Lng: ${detail.result.geometry.location.lng}');
        // ignore: omit_local_variable_types
        LatLng location = LatLng(detail.result.geometry.location.lat,
            detail.result.geometry.location.lng);
        await _mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: location, zoom: 17)));

        destinationController.text = p.description;
        _addMarker(location, p.description);
      } else {}
    } catch (e) {
      print(e);
    }
  }

  void onCameraMove(CameraPosition position) {
    _lastP = position.target;
    notifyListeners();
  }

  void onTapCameraMove(
      LatLng position, Completer<GoogleMapController> _controller) async {
    // ignore: omit_local_variable_types
    GoogleMapController _mapController = await _controller.future;
    await _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 17)));
    // ignore: omit_local_variable_types
    List<Placemark> _placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    // ignore: omit_local_variable_types
    String address =
        '${_placemark.first.country}  ${_placemark.first.locality}  ${_placemark.first.street}  ${_placemark.first.postalCode}';
    destinationController.text = address;
    _addMarker(position, address);
  }

  void getController(
      InAppWebViewController _controller, BuildContext context) async {
    controller = _controller;
    Future.delayed(Duration(seconds: 8), () {
      takeSnapshot(context);
    });
    notifyListeners();
  }

  void getControllerScreen(
      ScreenshotController _controller, BuildContext context) async {
    //controllerS = _controller;
    Future.delayed(Duration(seconds: 8), () async {
      await _controller
          .capture(delay: Duration(milliseconds: 10))
          .then((capturedImage) async {
        await showDialog(
          useSafeArea: false,
          context: context,
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text("Captured widget screenshot"),
            ),
            body: Center(
                child: capturedImage != null
                    ? Image.memory(capturedImage)
                    : Container(
                        child: Text('Vacio'),
                      )),
          ),
        );
      }).catchError((onError) {
        print(onError);
      });
    });
    // notifyListeners();
  }

  void takeSnapshot(BuildContext context) async {
    print(controller.getUrl());
    var data = await controller.takeScreenshot();
    await showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(child: data != null ? Image.memory(data) : Container()),
      ),
    );
  }

  void takeSnapshotPlugin(context) async {
    await controllerS
        .capture(delay: Duration(milliseconds: 10))
        .then((capturedImage) async {
      print(capturedImage);
      await showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Captured widget screenshot"),
          ),
          body: Center(
              child: capturedImage != null
                  ? Image.memory(capturedImage)
                  : Container(
                      child: Text('Vacio'),
                    )),
        ),
      );
    }).catchError((onError) {
      print(onError);
    });
  }
}
