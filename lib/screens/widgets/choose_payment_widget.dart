import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_app/Global.dart';
import 'package:service_app/providers/auth.dart';
import 'package:service_app/screens/web_payment_screen.dart';

import '../payment_screen.dart';

class ChoosePaymentWidget extends StatelessWidget {
  final String amount;
final Function onRazorpay;

  const ChoosePaymentWidget({
    Key key,
    @required this.amount,
    this.onRazorpay
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = Provider.of<Auth>(context).currentUser.id;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Payment Options',
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(bottom: 8.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.of(context)
          //           .push(
          //         MaterialPageRoute(
          //           builder: (ctx) => WebPaymentScreen(
          //             url:
          //                 'https://project.cander.in/flutter_service/Webservice/paypalWallent?amount=$amount&userId=$id',
          //           ),
          //         ),
          //       )
          //           .then((value) {
          //         print('Payment value: $value');
          //         Navigator.of(context).pop();
          //       });
          //     },
          //     child: Container(
          //       height: 60,
          //       child: Image.asset('assets/images/paypal_logo.png'),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                print('qqqqqqqqqqqqqqqqqqq');
                Navigator.of(context).pop(true);
                print('qqqqqqqqqqqqqqqqqqq');
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => PaymentScreen(
                //       email: email,
                //       mobile: mobile,
                //       isCustomer: isCustomer,
                //     ),
                //   ),
                // );
              },
              child: GestureDetector(
                onTap: (){
                  if(onRazorpay!=null)
                  onRazorpay();
                },
                child: Container(
                  height: 60,
                  child: Image.asset('assets/images/razorpay.png'),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(bottom: 8.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.of(context)
          //           .push(
          //         MaterialPageRoute(
          //           builder: (ctx) => WebPaymentScreen(
          //             url:
          //                 'https://project.cander.in/flutter_service/Stripe/Payment/make_payment/$id/$amount',
          //           ),
          //         ),
          //       )
          //           .then((value) {
          //         print('Payment value: $value');
          //         Navigator.of(context).pop();
          //       });
          //     },
          //     child: Container(
          //       height: 60,
          //       child: Image.asset('assets/images/stripe_logo.png'),
          //     ),
          //   ),
          // ),
          SizedBox(height: 20,),

          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              alignment: Alignment.center,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Theme.of(context).primaryColor,
              ),
              width: (MediaQuery.of(context).size.width / 2) - 20,
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
