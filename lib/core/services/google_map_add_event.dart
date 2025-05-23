import 'dart:async';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../view/view_layer.dart';
import '../data_layer.dart';


// open the map to select the event location
class AddEventMap extends StatefulWidget {
  const AddEventMap({Key? key}) : super(key: key);

  @override
  _AddEventMapState createState() => _AddEventMapState();
}

class _AddEventMapState extends State<AddEventMap> {
  late GoogleMapController mapController;
  final double defaultLat = 7.8731; // Sri Lanka center
  final double defaultLng = 80.7718;
  late CameraPosition cam_pos = CameraPosition(
      target: LatLng(sharedUser.latitude ?? defaultLat, sharedUser.longitude ?? defaultLng), zoom: 13);
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> markers = {};
  MapType currentMapType = MapType.hybrid;
  bool markerAdded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeManager.background,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_sharp,
            color: Colors.grey,
            size: 25,
          ),
        ),
        actions: [
          PopupMenuButton<MapType>(
            onSelected: (MapType result) {
              setState(() {
                currentMapType = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MapType>>[
              const PopupMenuItem<MapType>(
                value: MapType.normal,
                child: Text('Normal'),
              ),
              const PopupMenuItem<MapType>(
                value: MapType.satellite,
                child: Text('Satellite'),
              ),
              const PopupMenuItem<MapType>(
                value: MapType.terrain,
                child: Text('Terrain'),
              ),
              const PopupMenuItem<MapType>(
                value: MapType.hybrid,
                child: Text('Hybrid'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () {
              mapController.animateCamera(
                CameraUpdate.zoomIn(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: () {
              mapController.animateCamera(
                CameraUpdate.zoomOut(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapType: currentMapType,
              initialCameraPosition: cam_pos,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                mapController = controller;
              },
              onTap: _handleTap,
              markers: markers,
            ),
          ),
          if (markerAdded) // Show me the button if the marker is added
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(
                    LayoutManager.widthNHeight0(context, 1) * 0.15),
                child: defaultButton(
                  text: '       Done       ',
                  width: LayoutManager.widthNHeight0(context, 1) * 0.45,
                  borderRadius: 18,
                  background: ThemeManager.primary,
                  textColor: ThemeManager.second,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  borderWidth: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(LatLng tappedPoint) {
    setState(() {
      markers.clear();
      markers.add(Marker(
        markerId: MarkerId(tappedPoint.toString()),
        position: tappedPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
      markerAdded = true;
    });

    addEventLocatonLat = tappedPoint.latitude;
    addEventLocatonLog = tappedPoint.longitude;
  }

  @override
  void initState() {
    super.initState();
  }
}
