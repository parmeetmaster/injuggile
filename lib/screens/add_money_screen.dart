import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:service_app/core/http_client/http_helper.dart';
import 'package:service_app/providers/auth.dart';
import 'package:service_app/core/razor_pay/razor_pay.dart';
import 'package:service_app/providers/customer.dart';
import 'package:service_app/screens/widgets/choose_payment_widget.dart';
import 'package:service_app/screens/widgets/m_progress_indicator.dart';

import '../Global.dart';

class AddMoneyWidget extends StatefulWidget {
  final String currency;
  String amount="";

  AddMoneyWidget({
    Key key,

    @required this.currency,
  }) : super(key: key);

  @override
  _AddMoneyWidgetState createState() => _AddMoneyWidgetState();
}

class _AddMoneyWidgetState extends State<AddMoneyWidget> {
  final TextEditingController _amountController = TextEditingController();
  Razorpay _razorpay;

  String mobile;
  String email;
  bool isCustomer;

  @override
  void initState() {

    loadAmount();

    super.initState();
    /*   _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);*/
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

/*  void openCheckout() async {
    mobile = Provider.of<Auth>(context).currentUser.mobile;
    email = Provider.of<Auth>(context).currentUser.email;
    isCustomer = Provider.of<Auth>(context).currentUser.isCustomer;
    print('111111111111111$mobile');
    print('111111111111111$email');
    print('111111111111111$isCustomer');
    print(
        'error: amount: ${(double.parse(_amountController.text) * 100).round()}');
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': (double.parse(_amountController.text) * 100).round(),
      'currency': 'INR',
      'name': 'Injuggle India',
      'description':
          Provider.of<Auth>(context, listen: false).currentUser.isCustomer
              ? 'Customer'
              : 'Vendor',
      'image': 'https://rzp-mobile.s3.amazonaws.com/images/rzp.png',
      'prefill': {'contact': '9898989898', 'email': 'testuser@gmail.com'},
      'theme.color': '#0d1543',
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("SUCCESS: " + response.paymentId);
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, timeInSecForIosWeb: 4);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("ERROR: " + response.code.toString() + " - " + response.message);
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("EXTERNAL_WALLET: " + response.walletName);
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIosWeb: 4);
  }*/

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Money'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                color: Colors.white,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Balance\n',
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Colors.grey, fontSize: 18),
                      ),
                      TextSpan(
                        text: '${widget.currency} ${widget.amount}',
                        style: Theme.of(context).textTheme.headline6.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2.1,
                  child: Image.asset(
                    'assets/images/wa.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Amount',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Builder(
                builder: (ctx) => Padding(
                  padding: EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    top: 4.0,
                    bottom: 4.0,
                  ),
                  child: RaisedButton(
                    child: Center(
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          'Add Money',
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (_amountController.text == null ||
                          _amountController.text.isEmpty ||
                          double.parse(_amountController.text) <= 0) {
                        Scaffold.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Please Enter A valid Amount!'),
                          ),
                        );
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      showModalBottomSheet(
                        isDismissible: true,
                        isScrollControlled: true,
                        context: context,
                        builder: (mcontext) {
                          return ChoosePaymentWidget(
                            amount: _amountController.text,
                            onRazorpay: () async {
                              print("I called once");

                              try {
                                MProgressIndicator.show(context);
                                Auth auth =
                                    Provider.of<Auth>(context, listen: false);
                                Navigator.pop(mcontext);
                                RazorPayHelper.payAmount(
                                    double.parse(_amountController.text),
                                    onSuccessmethod:
                                        (PaymentSuccessResponse rzresp) async {
                                  var map = {
                                    'user_id': auth.currentUser.id,
                                    'amount': _amountController.text,
                                    'payid': rzresp.paymentId,
                                  };
                                  ApiResponse response =
                                      await HttpHelper.postForm(path: "/addmoney",body: map);

                                  final provider = Provider.of<Customer>(
                                      context,
                                      listen: false);
                                  await provider.getWallet();
                                  MProgressIndicator.hide();
                                  setState(() {
                                    widget.amount = provider.wallet.amount;
                                  });

                                  Flushbar(
                                    title: "Payment Success",
                                    message:
                                        "${response.message ?? "Payment complete"}",
                                    duration: Duration(seconds: 3),
                                  )..show(context);
                                }, onFailure: () {
                                  Navigator.pop(mcontext);
                                  Flushbar(
                                    title: "Failed Payment",
                                    message:
                                        "Payment not done please contact at injuggleoffice@gmail.com",
                                    duration: Duration(seconds: 3),
                                  )..show(context);
                                });
                              } catch (e) {}
                            },
                          );
                        },
                      ).then((value) {
                        if (value) {}
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loadAmount() async{
    final provider = Provider.of<Customer>(
        context,
        listen: false);
    await provider.getWallet();
    MProgressIndicator.hide();
    setState(() {
      widget.amount = provider.wallet.amount;
    });
  }
}
