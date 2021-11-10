import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:service_app/providers/auth.dart';
import 'package:service_app/screens/widgets/custom_drawer.dart';
import 'package:share/share.dart';

import '../Global.dart';

class DiscountReferalCodeScreen extends StatefulWidget {
  @override
  _DiscountReferalCodeScreenState createState() => _DiscountReferalCodeScreenState();
}

class _DiscountReferalCodeScreenState extends State<DiscountReferalCodeScreen> {
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
              title: Text('Refer & Earn'),

              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        elevation: 8.0,
                        child: Padding(
                          padding: const EdgeInsets.only(left:8.0,right:8.0,bottom: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height / 2.5,
                                child: Image.asset('assets/images/refcodeimage.jpg'),
                              ),
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
                      Padding(
                        padding: const EdgeInsets.only(top:10.0),
                        child: ElevatedButton(
                            onPressed: () {
                              Share.share("This is my Referral Code: " + user.refCode + " Use this Code and Enjoy the Service!", subject: 'Service App Referral Code');
                            },
                            child: Text('SHARE WITH A FRIEND')),
                      )
                    ],
                  ),
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
