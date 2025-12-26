import 'package:flutter/material.dart';
import '../services/api_services/auth_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final AuthApi authApi = AuthApi();
  String? receivedOtp;
  bool otpSent = false;
  bool isLoading = false;
  bool isNewUser = false;
  bool otpVerified = false;

  Future<void> sendOtp() async {
    final mobile = phoneController.text.trim();

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid 10-digit phone number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);
      final response = await authApi.sendOtp(mobile);
      
      setState(() {
        otpSent = true;
        isLoading = false;
        receivedOtp = response['otp'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("OTP sent! (Test OTP: $receivedOtp)"),
          backgroundColor: const Color(0xFF00C853),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send OTP: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyOtp() async {
    final mobile = phoneController.text.trim();
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid 6-digit OTP"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);
      final response = await authApi.validateOtp(mobile, otp);
      
      setState(() {
        isLoading = false;
        otpVerified = true;
        isNewUser = response['isNewUser'] ?? false;
      });

      if (isNewUser) {
        // Show profile completion form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP verified! Please complete your profile"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Existing user - navigate to home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("OTP verification failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> completeProfile() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);
      final userData = {
        'mobileNumber': phoneController.text.trim(),
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
      };

      await authApi.completeProfile(userData);
      
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile completed successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile completion failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Get Started with EV Charging Locator",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.electric_car,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 40),

              // Phone number input
              if (!otpVerified)
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: "Phone Number",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixText: "+91 ",
                    prefixStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 20),

              // Get OTP button
              if (!otpSent && !otpVerified)
                ElevatedButton(
                  onPressed: isLoading ? null : sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00C853),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : const Text("Get OTP"),
                ),

              // OTP input
              if (otpSent && !otpVerified) ...[
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: "Enter OTP",
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00C853),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : const Text("Verify OTP"),
                ),
              ],

              // Profile completion form for new users
              if (isNewUser && otpVerified) ...[
                const SizedBox(height: 20),
                const Text(
                  "Complete Your Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: "Full Name",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: "Email Address",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00C853),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.green)
                      : const Text("Complete Profile"),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}