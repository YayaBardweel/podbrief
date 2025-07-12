import 'package:flutter/material.dart';

// Define a constant for the primary color to ensure consistency.
const Color kPrimaryColor = Color(0xFF5E35B1);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Private State class for RegisterPage.
class _RegisterPageState extends State<RegisterPage> {
  // Controllers for text fields to manage their state.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController(); // Controller for phone number.

  // Method to handle user registration.
  void _registerUser() {
    // Trim whitespace from input fields.
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim(); // Get phone number.

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match")),
      );
      return;
    }

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number cannot be empty")),
      );
      return;
    }

    // TODO: Firebase Auth registration goes here
  }

  @override
  // Build method for the widget tree.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(90.0),
          child: const Text('Register'),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Consistent padding.
        child: Column(
          children: [
            const SizedBox(height: 24.0), // Consistent spacing.

            // Email TextField
            _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              prefixIcon: Icons.email,
            ),

            const SizedBox(height: 16.0), // Consistent spacing.

            // Password TextField
            _buildTextField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock,
              obscureText: true,
            ),

            const SizedBox(height: 16.0), // Consistent spacing.

            // Confirm Password TextField
            _buildTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),

            const SizedBox(height: 16.0), // Consistent spacing.

            // Phone Number TextField
            _buildTextField(
              controller: _phoneNumberController,
              labelText: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone, // Set keyboard type for phone number.
            ),

            const SizedBox(height: 24.0), // Consistent spacing.

            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerUser, // Call the private registration method.
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14.0), // Consistent padding.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Consistent border radius.
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 16.0, color: Colors.white), // Ensure text is visible.
                ),
              ),
            ),

            const SizedBox(height: 24.0), // Consistent spacing.

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back to the Login page.
                  },
                  child: Text(
                    'Login Now',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ), // Consistent styling.
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build TextFields with consistent styling.
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: kPrimaryColor), // Icon color matches primary.
        labelStyle: TextStyle(color: kPrimaryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor, width: 2.0), // Thicker border when focused.
          borderRadius: BorderRadius.circular(12.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
