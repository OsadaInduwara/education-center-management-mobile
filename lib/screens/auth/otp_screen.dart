import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OtpEntryScreen extends StatefulWidget {
  final String msisdn;
  const OtpEntryScreen({Key? key, required this.msisdn}) : super(key: key);

  @override
  _OtpEntryScreenState createState() => _OtpEntryScreenState();
}

class _OtpEntryScreenState extends State<OtpEntryScreen> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> _verifyOTP() async {
    String otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter OTP")));
      return;
    }
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('verifyOTP');
      final result = await callable.call({'msisdn': widget.msisdn, 'otp': otp});
      if (result.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subscription successful")));
        // Navigate to premium page after a brief delay
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
            const Text("Enter the OTP sent to your mobile"),
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
