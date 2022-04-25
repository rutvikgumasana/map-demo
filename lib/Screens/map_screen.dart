import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Controllers/map_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late GoogleMapController mapController;
  String? mapStyle;
  Timer? timer;

  double lat = 51.5160895;
  double lng = -0.1294527;

  CameraPosition userPosition = const CameraPosition(
    target: LatLng(21.1702, 72.8311),
    zoom: 12,
  );

  Marker userMarker = const Marker(
      markerId: MarkerId("current Location"),
      position: LatLng(21.1702, 72.8311),
      icon: BitmapDescriptor.defaultMarker);

  @override
  void initState() {
    super.initState();
    mapCreate();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          GoogleMap(
            // tiltGesturesEnabled: false,
            // rotateGesturesEnabled: true,
            // scrollGesturesEnabled: true,
            // zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onTap: (position) {
              changeCureentLocation(position: position);
              // _customInfoWindowController.hideInfoWindow();
            },
            // onCameraMove: (position) {
            //   // _customInfoWindowController.onCameraMove();
            // },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: userPosition,
            markers: {userMarker},
            // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            //   new Factory<OneSequenceGestureRecognizer>(
            //     () => new EagerGestureRecognizer(),
            //   ),
            // ].toSet(),
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                mapController = controller;
                // try {
                //   _controller.complete(controller);
                // } catch (err) {
                //   print(err);
                // }
                // _customInfoWindowController.googleMapController = controller;
                mapController.setMapStyle(mapStyle);
              });
            },
          ),
          Positioned(
            bottom: 70,
            left: 10,
            child: Card(
              elevation: 2,
              child: Container(
                color: const Color(0xFFFAFAFA),
                width: 40,
                height: 100,
                child: Column(
                  children: <Widget>[
                    IconButton(
                        color: Colors.black,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.amber,
                        ),
                        onPressed: () async {
                          var currentZoomLevel =
                              await mapController.getZoomLevel();

                          currentZoomLevel = currentZoomLevel + 1;
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: userPosition.target,
                                zoom: currentZoomLevel,
                              ),
                            ),
                          );
                        }),
                    const SizedBox(height: 2),
                    IconButton(
                        color: Colors.black,
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.amber,
                        ),
                        onPressed: () async {
                          var currentZoomLevel =
                              await mapController.getZoomLevel();
                          currentZoomLevel = currentZoomLevel - 1;
                          if (currentZoomLevel < 0) currentZoomLevel = 0;
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: userPosition.target,
                                zoom: currentZoomLevel,
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // change current location
  changeCureentLocation({LatLng? position}) {
    setState(() {
      userPosition = CameraPosition(
        target: position!,
        zoom: 12,
      );
      userMarker = Marker(
          markerId: const MarkerId("current Location"),
          position: position,
          icon: BitmapDescriptor.defaultMarker);
    });
  }

  // map Create
  mapCreate() {
    MapScreenController().determinePosition().then((position) {
      lat = position.latitude;
      lng = position.longitude;
      userPosition = CameraPosition(
        target: LatLng(lat, lng),
        zoom: 12,
      );
      userMarker = Marker(
          markerId: const MarkerId("current Location"),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarker);
      userPosition = CameraPosition(
        target: LatLng(lat, lng),
        zoom: 12,
      );
      log(lat.toString());
      log(lng.toString());
      setState(() {});
      if (!mounted) {
        return;
      }
    });
  }

  void startTimer() async {
    timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      final position = await GeolocatorPlatform.instance.getCurrentPosition();
      addCurrentLocation(position);
    });
  }

  void addCurrentLocation(Position positionn) {
    firestore.collection("CurrentPositionList").doc("Rutvik").set(
        {"latitude": positionn.latitude, "longitude": positionn.longitude});
  }
}
