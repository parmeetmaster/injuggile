import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:service_app/providers/auth.dart';
import 'package:share/share.dart';

import '../../Global.dart';
import 'custom_drawer.dart';

class DiscountCodeVendorScreen extends StatefulWidget {
  @override
  _DiscountCodeVendorScreenState createState() => _DiscountCodeVendorScreenState();
}

class _DiscountCodeVendorScreenState extends State<DiscountCodeVendorScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context).currentUser;
    return user != null
        ? Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => CustomDrawer.of(context).open(),
                  );
                },
              ),
              elevation: 0,
              title: Text('Get Discount'),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 8.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                'Refer your friends and earn money with referral links. U Clab Services is a smartphone app that allows users to easily sell and buy Services. To get started with the referral program, just copy the code below and share it with a friend or click Invite Friend button to share directly to your favourite communications app. When your friend buys or sells any service through the app, you will both earn up to 50% of the profit made made by the company involved in that deal!',
                                style: Theme.of(context).textTheme.headline6),
                            Card(
                              color: Colors.blueGrey,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Your referral code: ',
                                          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
                                        ),
                                        Text(
                                          user.refCode,
                                          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await Clipboard.setData(
                                              ClipboardData(
                                                text: user.refCode,
                                              ),
                                            ).then((value) {
                                              Global.showSnackbarMessage('Code copied to clipboard!', Icons.info_outline, Colors.blue, context);
                                            });
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Share.share(user.refCode, subject: 'Service App Referral Code');
                        },
                        child: Text('SHARE WITH A FRIEND'))
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => CustomDrawer.of(context).open(),
                  );
                },
              ),
              elevation: 0,
              title: Text('Get Discount'),
              centerTitle: true,
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
