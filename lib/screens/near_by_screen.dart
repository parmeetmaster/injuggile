import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:service_app/providers/auth.dart';
import 'package:service_app/providers/customer.dart';
import 'package:service_app/screens/artist_details_screen.dart';

import 'globalScreens/customLocation.dart';

class NearByScreen extends StatefulWidget {
  static const routeName = '/near-by-screen';

  @override
  _NearByScreenState createState() => _NearByScreenState();
}

class _NearByScreenState extends State<NearByScreen> {
  LocationData position;

  @override
  void initState() {
   setUpLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context).currentUser;
    final artists = Provider.of<Customer>(context).artists;
    final markers = artists
        .map(
          (artist) => Marker(
            infoWindow: InfoWindow(
              onTap: () {
                print('info tapped!');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) {
                      return ArtistDetailsScreen(
                        artistId: artist.id,
                      );
                    },
                  ),
                );
              },
              title: artist.name,
              snippet: artist.categoryName,
            ),
            markerId: MarkerId(artist.id),
            position: LatLng(
              double.parse(artist.latitude),
              double.parse(artist.longitude),
            ),
          ),
        )
        .toSet();
    markers.add(
      Marker(
        markerId: MarkerId('user-location'),
        infoWindow: InfoWindow(title: user.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(
          double.parse(user.liveLat),
          double.parse(user.liveLong),
        ),
      ),
    );
    final appBar = AppBar(
      centerTitle: true,
      title: Text('Service'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: Container(
        height:
            MediaQuery.of(context).size.height - appBar.preferredSize.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          initialCameraPosition: camera_location,
          onMapCreated: (GoogleMapController controller) {},
          markers: markers,
        ),
      ),
    );
  }

  CameraPosition camera_location = CameraPosition(
   // bearing: 192.8334901395799,
    target: LatLng(17.385, 78.4867),
    zoom: 12.151926040649414,
  );

  void setUpLocation() async {
    position = await CustomLocation().getLocation();
    if (position.latitude.isNaN == false) {
      camera_location = CameraPosition(
         // bearing: 192.8334901395799,
          target: LatLng(position.latitude, position.longitude),
          zoom: 40.151926040649414);
    }
    setState(() {});
  }
}
