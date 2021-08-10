import 'dart:async';

import 'package:example/src/provider/maps_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/distance.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GoogleMaps extends StatelessWidget {
  final Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    // ignore: omit_local_variable_types

    return ChangeNotifierProvider<Maps_Data>(
      create: (context) => Maps_Data(),
      child: Consumer<Maps_Data>(builder: (_, value, __) {
        return FutureBuilder<List<double>>(
          future: value.getUserLocation(),
          builder: (_, map) {
            // ignore: omit_local_variable_types
            List<double> maps = map.data;
            return !map.hasData
                ? Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Stack(
                    children: <Widget>[
                      GoogleMap(
                        mapType: MapType.normal,
                        markers: value.markers,
                        initialCameraPosition: CameraPosition(
                            zoom: 17, target: LatLng(maps?.first, maps?.last)),
                        myLocationEnabled: true,
                        buildingsEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        onCameraMove: value.onCameraMove,
                        onMapCreated: (controller) =>
                            _controller.complete(controller),
                        onTap: (argument) =>
                            value.onTapCameraMove(argument, _controller),
                      ),
                      Positioned(
                        top: 10.0,
                        right: 15.0,
                        left: 15.0,
                        child: Container(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(1.0, 5.0),
                                    blurRadius: 30,
                                    spreadRadius: 3)
                              ]),
                          child: TextField(
                            readOnly: true,
                            cursorColor: Colors.black,
                            controller: value.destinationController,
                            textInputAction: TextInputAction.go,
                            onTap: () async {
                              try {
                                // ignore: omit_local_variable_types
                                Prediction p = await PlacesAutocomplete.show(
                                    region: 'mx',
                                    sessionToken: 'sessionToken',
                                    types: ['(cities)'],
                                    context: context,
                                    apiKey:
                                        'AIzaSyCUUWOZTunTAP8AHftO6u6uP3sntmyz0ZQ',
                                    mode: Mode.overlay,
                                    language: 'es',
                                    components: [
                                      Component(Component.country, 'mx')
                                    ]);
                                value.sendRequest(
                                    p, context, 'Mapa', _controller);
                              } catch (e) {
                                // ignore: avoid_print
                                print(e);
                              }
                            },
                            decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 10,
                                height: 10,
                                child: Icon(Icons.map),
                              ),
                              hintText: 'Buscar...',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 15.0, top: 10.0),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
          },
        );
      }),
    );
  }
}
