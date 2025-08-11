import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app/src/components/auth_input.dart';
import 'package:mobile_app/src/pages/register.dart';
import 'package:mobile_app/src/pages/tab_bar_view.dart';
import 'package:mobile_app/src/services/google_signin_config.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> _onSubmitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TabBarPage()),
          (Route<dynamic> route) => false,
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      print('🔍 Starting Google Sign-In process...');

      // Use centralized configuration
      final GoogleSignIn googleSignIn = GoogleSignInConfig.instance;

      // Sign out first to ensure account picker shows
      await googleSignIn.signOut();
      print('🔄 Signed out from previous session');

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Google sign-in was cancelled by the user.');
        setState(() => _isGoogleLoading = false);
        return;
      }

      print('✅ Google user obtained: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      print('🔑 Getting authentication tokens...');

      // Check if we have the required tokens
      if (googleAuth.idToken == null) {
        throw Exception(
            '❌ Failed to get ID token from Google. This usually means SHA-1 fingerprint is not configured in Firebase Console.');
      }

      print('✅ ID Token received: ${googleAuth.idToken?.substring(0, 10)}...');

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      print('🔐 Signing in to Firebase...');
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print('✅ Firebase sign-in successful: ${userCredential.user?.email}');

      // Store user info in Firestore if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        print('👤 New user detected, storing profile...');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': googleUser.displayName?.split(' ').first ?? '',
          'lastName':
              googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
          'email': googleUser.email,
          'photoURL': googleUser.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'provider': 'google',
        });
        print('✅ User profile stored in Firestore');
      }

      if (mounted) {
        print('🚀 Navigating to main app...');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TabBarPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('❌ Google sign-in error: $e');

      String errorMessage = 'Google sign-in failed';
      if (e.toString().contains('SHA-1') || e.toString().contains('ID token')) {
        errorMessage =
            'Google Sign-In not configured properly. Please add SHA-1 fingerprint to Firebase Console.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage =
            'Google Play Services error. Please update Google Play Services.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
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
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        // Check if Tab key is pressed
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          _navigateToSignup();
          return KeyEventResult.handled; // Consume the event
        }
        return KeyEventResult.ignored; // Don't consume the event
      },
      child: Scaffold(
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
                Text("Welcome to",
                    style: TextStyle(
                        fontSize: 24.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text("Our clothesline app",
                    style: TextStyle(
                        fontSize: 19.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 12.h),
                Text(
                  "Please log in to your account to continue",
                  style:
                      TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2.h),
                // Add hint text for Tab key functionality
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withAlpha(100)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.keyboard_tab,
                        color: Colors.white70,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email or Phone number",
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.w500)),
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
                      SizedBox(height: 6.h),
                      Text("Password",
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.w500)),
                      SizedBox(height: 0.2.h),
                      AuthInputField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromRGBO(244, 104, 72, 1),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(61, 63, 82, 1),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    minimumSize: Size(double.infinity, 7.h),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Login",
                          style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
                SizedBox(height: 4.h),
                ElevatedButton.icon(
                  icon: _isGoogleLoading
                      ? const CircularProgressIndicator()
                      : Image.asset('assets/images/google_logo.png',
                          height: 24),
                  label: Text(
                    _isGoogleLoading ? "Signing in..." : 'Sign in with Google',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don’t have an account?",
                        style: TextStyle(fontSize: 16.sp)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      ),
                      child: Text(
                        "  Please register",
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color.fromRGBO(212, 52, 24, 1)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
              ],
            ),
          ),
        ),
      ), // Close Focus widget
    );
  }
}
