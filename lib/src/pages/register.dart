import 'package:flutter/material.dart';
import 'package:mobile_app/src/components/auth_input.dart';
import 'package:mobile_app/src/services/google_signin_config.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/src/pages/tab_bar_view.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController =
  TextEditingController(); // Add password controller

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  Future<void> _onSubmitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        debugPrint('Email: "$email"');
        debugPrint('Email code units: ${email.codeUnits}');

        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          await FirebaseFirestore.instance.collection('users').doc(
              userCredential.user!.uid).set({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),

          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context); // Go back to login or home
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      print('🔍 Starting Google Sign-Up process...');
      
      // Use centralized configuration
      final GoogleSignIn googleSignIn = GoogleSignInConfig.instance;
      
      // Sign out first to ensure account picker shows
      await googleSignIn.signOut();
      print('🔄 Signed out from previous session');
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Google sign-up was cancelled by the user.');
        setState(() => _isGoogleLoading = false);
        return;
      }

      print('✅ Google user obtained: ${googleUser.email}');
      
      final googleAuth = await googleUser.authentication;
      print('🔑 Getting authentication tokens...');
      
      // Check if we have the required tokens
      if (googleAuth.idToken == null) {
        throw Exception('❌ Failed to get ID token from Google. This usually means SHA-1 fingerprint is not configured in Firebase Console.');
      }
      
      print('✅ ID Token received: ${googleAuth.idToken?.substring(0, 10)}...');
      
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      print('🔐 Signing in to Firebase...');
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      print('✅ Firebase sign-in successful: ${userCredential.user?.email}');
      
      // Store user info in Firestore (always for Google sign-up)
      print('👤 Storing user profile...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': googleUser.displayName?.split(' ').first ?? '',
        'lastName': googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
        'email': googleUser.email,
        'phone': '', // Empty since we don't get phone from Google
        'photoURL': googleUser.photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'provider': 'google',
      });
      print('✅ User profile stored in Firestore');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful with Google!'),
            backgroundColor: Colors.green,
          ),
        );
        
        print('🚀 Navigating to main app...');
        // Navigate to TabBar
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TabBarPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Google sign-up error: $e');
      
      String errorMessage = 'Google sign-up failed';
      if (e.toString().contains('SHA-1') || e.toString().contains('ID token')) {
        errorMessage = 'Google Sign-In not configured properly. Please add SHA-1 fingerprint to Firebase Console.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage = 'Google Play Services error. Please update Google Play Services.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: const AssetImage("assets/images/sky.png"),
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(128),
              BlendMode.darken,
            ),
          ),
        ),
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(21, 10, 10, 1),
                  letterSpacing: 1,
                  height: 0.0,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromRGBO(0, 0, 0, 1),
                      letterSpacing: 1,
                      height: 0.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      " Login",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromRGBO(212, 52, 24, 1),
                        letterSpacing: 1,
                        height: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "First Name",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromRGBO(21, 10, 10, 1),
                        letterSpacing: 1,
                        height: 0.0,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    AuthInputField(
                      controller: _firstNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "First name can't be empty";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "Last Name",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromRGBO(21, 10, 10, 1),
                        letterSpacing: 1,
                        height: 0.0,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    AuthInputField(
                      controller: _lastNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Last name can't be empty";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromRGBO(21, 10, 10, 1),
                        letterSpacing: 1,
                        height: 0.0,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    AuthInputField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter an email address";
                        } else if (!RegExp(
                            r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                            .hasMatch(value)) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "Phone",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromRGBO(21, 10, 10, 1),
                        letterSpacing: 1,
                        height: 0.0,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    AuthInputField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Phone number cannot be empty";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromRGBO(21, 10, 10, 1),
                        letterSpacing: 1,
                        height: 0.0,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    AuthInputField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter a password";
                        } else if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _onSubmitForm(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(61, 63, 82, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 1.3.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    minimumSize: Size(double.infinity, 7.h)),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 0.0,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton.icon(
                icon: _isGoogleLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey,
                        ),
                      )
                    : Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                label: Text(
                  _isGoogleLoading ? 'Signing up...' : 'Sign up with Google',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _isGoogleLoading ? null : _signUpWithGoogle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
