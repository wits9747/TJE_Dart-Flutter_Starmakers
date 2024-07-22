// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/constants.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final int price;
  final Function onSuccess;
  const CheckoutPage({Key? key, required this.price, required this.onSuccess})
      : super(key: key);

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    EasyLoading.dismiss();
    super.initState();
    amountController.text = (widget.price / 100).toString();
  }

  checkout() async {
    try {
      return await FlutterPaystackPlus.openPaystackPopup(
          publicKey: PaystackPublicKey,
          context: context,
          secretKey: PaystackSecretKey,
          currency: isDemo ? "ZAR" : AppConfig.currency,
          customerEmail: emailController.text,
          amount: widget.price.toString(),
          reference: 'ref_${DateTime.now().millisecondsSinceEpoch}',
          callBackUrl: "https://lamatt.web.app",
          onClosed: () {
            debugPrint('Could\'nt finish payment');
          },
          onSuccess: () async {
            debugPrint('Payment successful');
            await widget.onSuccess();
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          });
    } catch (e) {
      // EasyLoading.showError(LocaleKeys.purchaseFailed.tr());
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('Checkout Page')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: amountController,
                    readOnly: true,
                    canRequestFocus: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    // initialValue: widget.price.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefix: Text(
                        'R',
                        style:
                            Theme.of(context).inputDecorationTheme.prefixStyle,
                      ),
                      hintText: '2000',
                      // labelText: 'Amount',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'janedoe@who.com',
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          checkout();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Colors.white, //change background color of button
                        backgroundColor:
                            Colors.teal, //change text color of button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5.0,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          'Proceed to Pay',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
