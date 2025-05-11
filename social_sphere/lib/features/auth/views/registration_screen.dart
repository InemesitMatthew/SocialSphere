import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/form_validators.dart';
import '../controllers/auth_controller.dart';
import 'widgets/auth_widgets.dart';

// TODO: REDO THE COLORING OF THE BUTTONS AND TEXT FIELDS

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).createAccount(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // Update profile with display name if provided
      if (_nameController.text.isNotEmpty) {
        await ref.read(authControllerProvider.notifier).updateProfile(
              displayName: _nameController.text.trim(),
            );
      }

      // Navigation will be handled by AuthWrapper
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _errorMessage = null;
      _isGoogleLoading = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
      // Navigation will be handled by AuthWrapper
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 24),

                  // Welcome text
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join our community today!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Error message if any
                  if (_errorMessage != null) ...[
                    AuthErrorMessage(message: _errorMessage!),
                    const SizedBox(height: 16),
                  ],

                  // Name field
                  AuthTextField(
                    label: 'Display Name',
                    controller: _nameController,
                    validator: FormValidators.validateName,
                    prefixIcon: const Icon(Icons.person_outline),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  AuthTextField(
                    label: 'Email',
                    controller: _emailController,
                    validator: FormValidators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  AuthTextField(
                    label: 'Password',
                    controller: _passwordController,
                    validator: FormValidators.validatePassword,
                    obscureText: !_isPasswordVisible,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password field
                  AuthTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    validator: (value) =>
                        FormValidators.validatePasswordConfirmation(
                      value,
                      _passwordController.text,
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _register(),
                  ),
                  const SizedBox(height: 24),

                  // Register button
                  AuthButton(
                    text: 'Create Account',
                    onPressed: _register,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // OR divider
                  const DividerWithText(text: 'OR'),
                  const SizedBox(height: 24),

                  // Google sign up button
                  GoogleSignInButton(
                    onPressed: _signInWithGoogle,
                    isLoading: _isGoogleLoading,
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
