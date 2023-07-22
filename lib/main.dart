import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'package:pay/pay.dart';
import 'payment_configuration.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UpiIndia _upiIndia = UpiIndia();
  Future<UpiResponse>? _transaction;
  // UnComment this to detect all UPI apps on device
  // List<UpiApp>? apps;
  //
  // @override
  // void initState() {
  //   _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
  //     setState(() {
  //       apps = value;
  //     });
  //   }).catchError((e) {
  //     apps = [];
  //   });
  //   super.initState();
  // }
  UpiApp app =
      UpiApp.googlePay; //change this to accept particular payment/UPI app
  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "7887262254@paytm",
      receiverName: 'Flutter test',
      transactionRefId: 'TestingUpiIndiaPlugin',
      transactionNote: 'Not actual. Just an example.',
      amount: 1.00,
    );
  }

  //https://github.com/azhar1038/UPI-Plugin-Flutter/blob/main/example/lib/main.dart#L104
  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  TextStyle value = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        //TODO: add UPI Success
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        //TODO: add UPI Submitted
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        //TODO: add UPI FAILURE
        break;
      default:
        print('Received an Unknown transaction status');
      ////TODO: I DON"T KNOW WHAT I AM DOING
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
            body,
            style: value,
          )),
        ],
      ),
    );
  }

  Widget displayUPIapp() {
    return GestureDetector(
      onTap: () {
        _transaction = initiateTransaction(app);
        setState(() {});
      },
      child: Container(
        height: 100,
        width: 100,
        child: Image(
          image: NetworkImage(
              'https://hindubabynames.info/downloads/wp-content/themes/hbn_download/download/banking-and-finance/google-pay-logo.png'),
        ),
      ),
    );
  }

  //---------------------------------------------------
  var googlePayButton = GooglePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
    paymentItems: [
      PaymentItem(
        label: 'Total',
        amount: '99.99',
        status: PaymentItemStatus.final_price,
      )
    ],
    width: double.infinity,
    type: GooglePayButtonType.pay,
    onPaymentResult: onGooglePayResult,
    loadingIndicator: Center(
      child: CircularProgressIndicator(),
    ),
  );

  static void onGooglePayResult(paymentResult) {
    //TODO: do thingy when transaction go through
    var token = paymentResult;
    print(token);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              googlePayButton,
              Expanded(
                child: displayUPIapp(),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _transaction,
                  builder: (BuildContext context,
                      AsyncSnapshot<UpiResponse> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            _upiErrorHandler(snapshot.error.runtimeType),
                            style: header,
                          ), // Print's text message on screen
                        );
                      }

                      // If we have data then definitely we will have UpiResponse.
                      // It cannot be null
                      UpiResponse _upiResponse = snapshot.data!;

                      // Data in UpiResponse can be null. Check before printing
                      String txnId = _upiResponse.transactionId ?? 'N/A';
                      String resCode = _upiResponse.responseCode ?? 'N/A';
                      String txnRef = _upiResponse.transactionRefId ?? 'N/A';
                      String status = _upiResponse.status ?? 'N/A';
                      String approvalRef = _upiResponse.approvalRefNo ?? 'N/A';
                      _checkTxnStatus(status);

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            displayTransactionData('Transaction Id', txnId),
                            displayTransactionData('Response Code', resCode),
                            displayTransactionData('Reference Id', txnRef),
                            displayTransactionData(
                                'Status', status.toUpperCase()),
                            displayTransactionData('Approval No', approvalRef),
                          ],
                        ),
                      );
                    } else
                      return Center(
                        child: Text(''),
                      );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
