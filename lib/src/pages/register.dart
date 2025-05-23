import 'package:flutter/material.dart';
import 'package:mobile_app/src/components/auth_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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

  void _onSubmitForm() {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      debugPrint(firstName);
      debugPrint(lastName);
      debugPrint(email);
      debugPrint(phone);

      // This is where you make a call to the backend for register using the above credentials
    } else {
      return;
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
              Colors.black.withOpacity(0.5),
              BlendMode.dstATop,
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
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: () => _onSubmitForm(),
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
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
