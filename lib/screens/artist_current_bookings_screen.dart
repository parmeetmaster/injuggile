import 'dart:async';

import 'package:dp_stopwatch/dp_stopwatch.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:service_app/providers/auth.dart';
import 'package:service_app/providers/jobs_provider.dart';
import 'package:service_app/screens/widgets/custom_drawer.dart';

class ArtistCurrentBookingsScreen extends StatefulWidget {
  static const routeName = '/artist-current-bookings-screen';

  const ArtistCurrentBookingsScreen({Key key}) : super(key: key);

  @override
  _ArtistCurrentBookingsScreenState createState() =>
      _ArtistCurrentBookingsScreenState();
}

class _ArtistCurrentBookingsScreenState
    extends State<ArtistCurrentBookingsScreen> {
  String time = '00.00.00';
  bool isInit = true;

  final DPStopwatchViewModel stopwatchViewModel = DPStopwatchViewModel(
    clockTextStyle: const TextStyle(
      color: Colors.lightBlueAccent,
      fontSize: 22,
    ),
  );

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      timer.cancel();
      stopwatchViewModel?.start?.call();
    });

    super.initState();

  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      Provider.of<JobProvider>(context, listen: false)
          .getCurrentBookingsArtist()
          .then((value) {
        setState(() {
          isInit = false;
        });
      });
    }
    stopwatchViewModel.resume?.call();
    super.didChangeDependencies();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {



    final booking = Provider.of<JobProvider>(context).currentBooking;
    final user = Provider.of<Auth>(context).currentUser;
    final appBar = AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => CustomDrawer.of(context).open(),
          );
        },
      ),
      title: Text('Current Booking'),
      centerTitle: true,
    );

    _buildGoogleMap(BuildContext ctx) {
      return Container(
        height:
            MediaQuery.of(context).size.height - appBar.preferredSize.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          initialCameraPosition: CameraPosition(
              target: LatLng(
                double.parse(user.liveLat),
                double.parse(user.liveLong),
              ),
              zoom: 14),
          onMapCreated: (GoogleMapController controller) {},
          markers: [
            Marker(
              markerId: MarkerId('user-location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position: LatLng(
                double.parse(user.liveLat),
                double.parse(user.liveLong),
              ),
            ),
          ].toSet(),
        ),
      );
    }

    _buildNoRequestContainer(BuildContext ctx) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: 20.0),
            height: 60,
            width: MediaQuery.of(ctx).size.width - 20.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                'NO REQUEST FOUND',
                style: Theme.of(context).textTheme.headline6.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            )),
      );
    }

    _buildRequestContainer(BuildContext ctx) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2.0,
            child: Container(
              height: MediaQuery.of(context).size.height / 2.2,
              padding: EdgeInsets.all(8.0),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'New Request Found',
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          fontSize: 16,
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          booking.userImage != null && booking.userImage != ''
                              ? NetworkImage(booking.userImage)
                              : AssetImage('assets/images/dummyuser_image.jpg'),
                    ),
                  ),
                  Text(
                    booking.userName,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.date_range,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' ${booking.bookingDate} ${booking.bookingTime}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.location_on,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(text: ' ${booking.address}'),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.description,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextSpan(text: ' ${booking.description}'),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timelapse,
                        size: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      DPStopWatchWidget(
                        stopwatchViewModel,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        this.stopwatchViewModel.stop.call();
                        Provider.of<JobProvider>(
                          context,
                          listen: false,
                        ).bookingOperation('3', booking.id).then((value) {
                          Navigator.of(context).pushNamed('/');
                        });
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: Theme.of(context).primaryColor,
                        ),
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: Text(
                          'Finish The Job',
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      // drawer: AppDrawer(),
      appBar: appBar,
      body: isInit
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                _buildGoogleMap(context),
                booking.id == null || booking.id.isEmpty
                    ? _buildNoRequestContainer(context)
                    : _buildRequestContainer(context),
              ],
            ),
    );
  }
}
