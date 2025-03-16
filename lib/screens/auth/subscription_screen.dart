import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isSubscribed = false;
  final TextEditingController _msisdnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If you already store the user's mobile number (for example in Firestore or a provider),
    // load it here. Otherwise, leave it empty so the user can input.
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    // Assuming that the mobile number is stored in Firestore under the 'subscriptions' collection,
    // and you have a way to obtain the current user's mobile number.
    // If you don't have it yet, _msisdnController.text will be empty, and _isSubscribed remains false.
    String msisdn = _msisdnController.text.trim();
    if (msisdn.isNotEmpty) {
      final doc = await FirebaseFirestore.instance.collection('subscriptions').doc(msisdn).get();
      setState(() {
        _isSubscribed = doc.exists && (doc.data()!['subscribed'] == true);
      });
    } else {
      // No mobile number provided, so we assume the user is not subscribed.
      setState(() {
        _isSubscribed = false;
      });
    }
  }

  Future<void> _subscribe() async {
    String msisdn = _msisdnController.text.trim();
    if (msisdn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter your mobile number")));
      return;
    }
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('initiateSubscription');
      final result = await callable.call({'msisdn': msisdn});
      if (result.data['success']) {
        // Navigate to OTP entry screen for further verification
        Navigator.push(context, MaterialPageRoute(builder: (_) => OtpEntryScreen(msisdn: msisdn)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.data['message'])));
      }
    } catch (e) {
      print('Error subscribing: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("An error occurred")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: Center(
        child: _isSubscribed
            ? ElevatedButton(
            onPressed: () {
              // Navigate to premium content page if already subscribed
              Navigator.pushReplacementNamed(context, '/premiumPage');
            },
            child: const Text('Go to Premium Content'))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("To access premium content, please subscribe."),
              TextField(
                controller: _msisdnController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Enter your mobile number"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _subscribe,
                child: const Text("Subscribe"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpEntryScreen extends StatefulWidget {
  final String msisdn;
  const OtpEntryScreen({Key? key, required this.msisdn}) : super(key: key);

  @override
  State<OtpEntryScreen> createState() => _OtpEntryScreenState();
}

class _OtpEntryScreenState extends State<OtpEntryScreen> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> _verifyOTP() async {
    String otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter the OTP")));
      return;
    }
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('verifyOTP');
      final result = await callable.call({'msisdn': widget.msisdn, 'otp': otp});
      if (result.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subscription successful")));
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/premiumPage');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.data['message'])));
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("An error occurred")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter the OTP sent to your mobile number"),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
