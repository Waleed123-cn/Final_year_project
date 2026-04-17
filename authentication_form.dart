import 'package:digifun/components/common_widgets/custom_button.dart';
import 'package:digifun/components/common_widgets/custom_textfields.dart';
import 'package:digifun/components/common_widgets/customm_text.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:digifun/controllers/toogle_eye_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

Widget signUpForm({
  required GlobalKey<FormState> formKey,
  required TextEditingController userNameController,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController confirmPasswordController,
  required VoidCallback onPressed,
  required bool agreeToTerms,
  Color buttonTextColor = Colors.white,
  required ValueChanged<bool?> onAgreeToTermsChanged,
}) {
  return Consumer(
    builder: (context, ref, child) {
      final isLoading = ref.watch(isLoadingProvider);

      return Form(
        key: formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              customTextField(
                hintText: "Choose a fun username",
                icon: Icons.person,
                controller: userNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              customTextField(
                hintText: "Your email address",
                icon: Icons.email,
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              customTextField(
                controller: passwordController,
                hintText: "Create a password",
                icon: Icons.lock,
                isObscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              customTextField(
                controller: confirmPasswordController,
                hintText: "Confirm password",
                icon: Icons.lock,
                isObscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              /// Checkbox for Terms & Conditions
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: onAgreeToTermsChanged, // Update parent state
                    activeColor: Colors.red,
                  ),
                  const Expanded(
                    child: Text(
                      'I agree with Terms & Conditions',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              customButton(
                text: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )
                    : textSize16(
                        text: "Create Account",
                        color: buttonTextColor,
                      ),
                onPressed: isLoading || !agreeToTerms
                    ? null
                    : onPressed, // Disable if unchecked
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget loginForm({
  required GlobalKey<FormState> formKey,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required VoidCallback onPressed,
}) {
  return Consumer(
    builder: (context, ref, child) {
      final isLoading = ref.watch(isLoadingProvider);
      final isObscure = ref.watch(passwordVisibilityProvider);
      return Form(
        key: formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                child: customTextField(
                  hintText: "Your email address",
                  icon: Icons.email,
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: customTextField(
                  controller: passwordController,
                  hintText: "Enter your password",
                  icon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.blackColor,
                    ),
                    onPressed: () {
                      ref.read(passwordVisibilityProvider.notifier).toggle();
                    },
                  ),
                  isObscure: isObscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              customButton(
                  text: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : textSize16(
                          text: "Loign", color: AppColors.textPrimaryColor),
                  onPressed: isLoading ? null : onPressed),
            ],
          ),
        ),
      );
    },
  );
}
