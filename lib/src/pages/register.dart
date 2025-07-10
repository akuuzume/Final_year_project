import 'package:flutter/material.dart';
import 'package:mobile_app/src/components/auth_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


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

  bool _isLoading = false; // For loading state

  Future<void> _onSubmitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        debugPrint('Email: "$email"');
        debugPrint('Email code units: ${email.codeUnits}');

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Optionally, update displayName or save extra info to Firestore
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

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
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
                          return "First name can't be empty";
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "First name can't be empty";
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
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                  width: 24,

                ),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black, // Google button text is usually black
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
                onPressed: () async {
                try {
                final userCredential = await signInWithGoogle();
                if (userCredential != null) {
                Navigator.pushReplacementNamed(context, '/dashboard');
                } else {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Authentication failed.')),
                );
                }
                } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message ?? 'An error occurred')),
                );
                } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unexpected error occurred')),
                );
                }
                }

              ),
            ],
          ),
        ),
      ),
    );
  }
}
