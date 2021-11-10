import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:service_app/Global.dart';
import 'package:service_app/core/api/razorpay_api.dart';
import 'package:service_app/core/http_client/http_helper.dart';
import 'package:service_app/screens/widgets/m_progress_indicator.dart';

enum PaymentAction { SUCCESS, FAILED, EXTERNAL }

class RazorPayHelper {
  static Razorpay _razorpay = Razorpay();
  static Function(PaymentSuccessResponse) onSuccess;
  static Function() onFailure;
  static bool transaction_open = false;

  static Future<void> payAmount(
    double amount, {
    String description = null,
    Function(PaymentSuccessResponse) onSuccessmethod,
    Function onFailure,
  }) {
    transaction_open = true;
    onSuccess = onSuccessmethod;
    onFailure = onFailure;
    var options = {
      'key': 'rzp_live_VIXzOpUE7zWX0k',
      'amount': amount * 100,
      'name': 'InJuggle',
      'description': description ?? "Recharge Wallet",
      'prefill': {
        'contact': Global.user?.mobile ?? "",
        'email': 'injuggleoffice@gmail.com'
      }
    };
    _razorpay.open(options);

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  static _handlePaymentSuccess(PaymentSuccessResponse razresponse){
    print("RazorPAY PLUGIN RESPONSE===>  ${razresponse.toString()}");
    onSuccess(razresponse);
    MProgressIndicator.hide();
    _razorpay.clear();
  }

  static _handlePaymentError() {
    _razorpay.clear();
    MProgressIndicator.hide();
    onFailure();
  }

  static _handleExternalWallet() {
    MProgressIndicator.hide();
  }
}
